import 'package:flutter/material.dart';
import 'package:flutter_baji/models/craftsmanship_data.dart';
import 'package:get/get.dart';

import '../../controllers/craftsmanship_panel_controller.dart';
import '../../flutter_baji.dart';
import '../../models/badge_config.dart';
import '../../models/layer_data.dart';
import '../../utils/base_util.dart';
import '../confirm_bar.dart';
import '../custom_widget.dart';
import 'craftsmanship_type_list_widget.dart';
import 'fumo_item_widget.dart';
import 'fumo_type_list_widget.dart';
import 'layer_craftsmanship_list_widget.dart';

class CraftsmanshipPanel extends StatelessWidget {
  final controller = Get.put(CraftsmanshipPanelController());
  final VoidCallback? onClose;
  final VoidCallback? onConfirm;
  final List<LayerData> layerDatas;
  final ConfigSize size;
  final bool isCircle;
  final Function(List<LayerData> layerDatas, CraftsmanshipType currentEditType)
      onChangeGy;
  final Function(List<BjFumoData> fumoDatas, BjFumoData? data, ImageInfo? info)?
      onFumoSelect;

  CraftsmanshipPanel(
      {Key? key,
      required this.layerDatas,
      required this.onChangeGy,
      required this.isCircle,
      required this.size,
      this.onFumoSelect,
      this.onClose,
      this.onConfirm}) {
    controller.addlFumoListener(isCircle, onFumoSelect);
  }

  @override
  Widget build(BuildContext context) {
    return _content(context);
  }

  Widget _buildLayerContent(BuildContext context, bool isSmall) {
    return Obx(() => LayerCraftsmanshipListWidget(
        isSmall: isSmall,
        initLayerIndex: controller.currentLayerIndex.value,
        stickerPreDatas: layerDatas,
        onLayerTap: (index) {
          controller.currentLayerIndex.value = index + 1;
          controller.craftsmanshipActionIndex.value = 1;
        },
        onSave: (key) async {
          CraftsmanshipData? data =
              layerDatas[controller.currentLayerIndex.value - 1]
                  .craftsmanshipData;
          showSaveTypePop(context, onSaveJpg: () {
            _saveImage(key, context, true, data?.name ?? '');
          }, onSavePng: () {
            _saveImage(key, context, false, data?.name ?? '');
          });
        },
        fuMoItemWidget: Obx(
          () => GestureDetector(
            onTap: () {
              if (controller.selectedFumoIndex.value < 0) {
                return;
              }
              controller.currentLayerIndex.value = 0;
              controller.craftsmanshipActionIndex.value = 1;
            },
            child: FumoItemWidget(
              isSmall: isSmall,
              isSelect: controller.currentLayerIndex.value == 0,
              item: controller.selectedFumoIndex.value < 0
                  ? null
                  : controller.fumos[controller.selectedFumoIndex.value],
            ),
          ),
        )));
  }

  Widget _buildEditorContent() {
    return Obx(() => IndexedStack(
          index: controller.currentLayerIndex.value,
          children: [
            FumoTypeListWidget(
              fumos: controller.fumos,
              currentFumoData:
                  controller.fumos.isNotEmpty ? controller.fumos[0] : null,
              onTap: (data) {
                controller.selectedFumoIndex.value =
                    controller.fumos.indexOf(data);
              },
              onClose: () {
                controller.craftsmanshipActionIndex.value = 0;
              },
            ),
            ...layerDatas.map((item) {
              return CraftsmanshipTypeListWidget(
                canAddCraft:
                    (!item.localImgLayer && item.gongyi != null) || item.isFont,
                currentCraftsmanshipData: item.craftsmanshipData ??
                    CraftsmanshipData.craftsmanshipDatas[0],
                onTap: (data) {
                  layerDatas[controller.currentLayerIndex.value - 1]
                      .craftsmanshipData = data;
                  controller.craftsmanshipActionIndex.value = 0;
                  // 更新工艺层显示状态
                  for (var layer in layerDatas) {
                    layer.shouldShow =
                        layer.craftsmanshipData?.type == data.type;
                    layer.blackLayer =
                        layer.craftsmanshipData?.type == data.type;
                    if (data.type == CraftsmanshipType.none) {
                      layer.shouldShow = true;
                      layer.blackLayer = false;
                    }
                  }
                  onChangeGy(layerDatas, data.type);
                },
              );
            })
          ],
        ));
  }

  Widget _editor(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 91,
            alignment: Alignment.topCenter,
            child: _buildLayerContent(context, true)),
        Expanded(child: _buildEditorContent()),
      ],
    );
  }

  /// 图层
  Widget _layers(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildLayerContent(context, false)),
        ConfirmBar(
          cancel: () {
            // 将所有图层设置为无工艺
            for (var layer in layerDatas) {
              layer.craftsmanshipData = CraftsmanshipData.craftsmanshipDatas[0];
              layer.shouldShow = true;
              layer.blackLayer = false;
            }
            onChangeGy(layerDatas, CraftsmanshipType.none);
            onClose?.call();
          },
          confirm: () {
            onConfirm?.call(); // 将所有图层设置为无工艺
            for (var layer in layerDatas) {
              layer.shouldShow = true;
              layer.blackLayer = false;
            }
            onChangeGy(layerDatas, CraftsmanshipType.none);
          },
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '工艺',
                style: TextStyle(
                  color: Color(0xff969799),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _content(BuildContext context) {
    return Container(
        height: Get.height * 0.45,
        padding: const EdgeInsets.only(top: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Obx(() => IndexedStack(
              alignment: Alignment.topCenter,
              index: controller.craftsmanshipActionIndex.value,
              children: [
                _layers(context),
                _editor(context),
              ],
            )));
  }

  Future<void> _saveImage(
      GlobalKey key, BuildContext context, bool isJpg, String name) async {
    BaseUtil.showLoadingdialog(context);
    String? gy = await controller.saveBjGy(key, isCircle, size, name);
    await BajiUtil.saveImage(gy ?? '', true, isJpg);
    BaseUtil.hideLoadingdialog();
  }
}
