import 'package:fclash/main.dart';
import 'package:fclash/screen/controller/theme_controller.dart';
import 'package:fclash/service/autostart_service.dart';
import 'package:fclash/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';
import 'package:settings_ui/settings_ui.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    final config = Get.find<ClashService>().configEntity;
    const textStyle = TextStyle(fontFamily: 'nssc');
    return Obx(
      () => config.value == null
          ? BrnLoadingDialog(
              content: 'Loading'.tr,
            )
          : SettingsList(platform: DevicePlatform.iOS, sections: [
              SettingsSection(
                title: Text(
                  "Proxy".tr,
                  style: textStyle,
                ),
                tiles: [
                  SettingsTile.navigation(
                    title: Text(
                      "Proxy mode".tr,
                      style: textStyle,
                    ),
                    value: Text(config.value!.mode.toString()),
                    onPressed: (cxt) {
                      handleProxyMode();
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(
                      "Socks5 proxy port".tr,
                      style: textStyle,
                    ),
                    value: Text(
                      config.value!.socksPort.toString(),
                      style: textStyle,
                    ),
                    onPressed: (cxt) {
                      Get.find<DialogService>().inputDialog(
                          title: 'Enter custom port for Socks5 proxy port'.tr,
                          onText: (text) {
                            final port = int.tryParse(text);
                            if (port == null) {
                              BrnToast.show('no a valid port', context);
                            } else {
                              Get.find<ClashService>()
                                  .changeConfigField('socks-port', port);
                            }
                          });
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(
                      "HTTP proxy port".tr,
                      style: textStyle,
                    ),
                    value: Text(
                      config.value!.port.toString(),
                      style: textStyle,
                    ),
                    onPressed: (cxt) {
                      Get.find<DialogService>().inputDialog(
                          title: 'Enter custom port for HTTP proxy port'.tr,
                          onText: (text) {
                            final port = int.tryParse(text);
                            if (port == null) {
                              BrnToast.show('no a valid port'.tr, context);
                            } else {
                              Get.find<ClashService>()
                                  .changeConfigField('port', port);
                            }
                          });
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(
                      "Redir proxy port".tr,
                      style: textStyle,
                    ),
                    value: Text(
                      config.value!.redirPort.toString(),
                      style: textStyle,
                    ),
                    onPressed: (cxt) {
                      Get.find<DialogService>().inputDialog(
                          title: 'Enter custom port for redir proxy port'.tr,
                          onText: (text) {
                            final port = int.tryParse(text);
                            if (port == null) {
                              BrnToast.show('no a valid port'.tr, context);
                            } else {
                              Get.find<ClashService>()
                                  .changeConfigField('redir-port', port);
                            }
                          });
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(
                      "Mixed proxy port".tr,
                      style: textStyle,
                    ),
                    value: Text(
                      config.value!.mixedPort.toString(),
                      style: textStyle,
                    ),
                    onPressed: (cxt) {
                      Get.find<DialogService>().inputDialog(
                          title: 'Enter custom port for mixed proxy port'.tr,
                          onText: (text) {
                            final port = int.tryParse(text);
                            if (port == null) {
                              BrnToast.show('no a valid port'.tr, context);
                            } else {
                              Get.find<ClashService>()
                                  .changeConfigField('mixed-port', port);
                            }
                          });
                    },
                  ),
                  SettingsTile.switchTile(
                      title: Text(
                        "allow_lan".tr,
                        style: textStyle,
                      ),
                      initialValue: config.value?.allowLan,
                      onToggle: (e) {
                        Get.find<ClashService>()
                            .changeConfigField('allow-lan', e);
                      }),
                  SettingsTile.switchTile(
                      title: Text(
                        "Enable IPv6".tr,
                        style: textStyle,
                      ),
                      initialValue: config.value?.ipv6,
                      onToggle: (e) {
                        Get.find<ClashService>().changeConfigField('ipv6', e);
                      }),
                ],
              ),
              SettingsSection(
                  title: Text(
                    "System".tr,
                    style: textStyle,
                  ),
                  tiles: [
                    SettingsTile.navigation(
                      title: const Text(
                        'Language',
                        style: textStyle,
                      ),
                      onPressed: (cxt) {
                        Get.dialog(BrnSingleSelectDialog(
                          title: 'Language',
                          conditions: const ["中文", "English"],
                          onSubmitClick: (s) {
                            if (s != null) {
                              if (s == "English") {
                                Get.updateLocale(const Locale('en', 'US'));
                                SpUtil.setData('lan', 'en_US');
                              } else {
                                Get.updateLocale(const Locale('zh', 'CN'));
                                SpUtil.setData('lan', 'zh_CN');
                              }
                            }
                          },
                        ));
                      },
                    ),
                    SettingsTile.switchTile(
                        initialValue:
                            SpUtil.getData("dark_theme", defValue: false),
                        onToggle: (e) async {
                          if (e) {
                            await SpUtil.setData("dark_theme", true);
                          } else {
                            await SpUtil.setData("dark_theme", false);
                          }
                          Get.find<ThemeController>().changeTheme(
                              e ? ThemeType.dark : ThemeType.light);
                          setState(() {});
                        },
                        title: Text('Dark Theme'.tr)),
                      SettingsTile.switchTile(
                          title: Text(
                            "Set as system proxy".tr,
                            style: textStyle,
                          ),
                          initialValue:
                              SpUtil.getData("system_proxy", defValue: false),
                          onToggle: (e) async {
                            if (e) {
                              await Get.find<ClashService>().setSystemProxy();
                              await SpUtil.setData("system_proxy", true);
                            } else {
                              await Get.find<ClashService>().clearSystemProxy();
                              await SpUtil.setData("system_proxy", false);
                            }
                            setState(() {
                              Tips.info("success");
                            });
                          }),
                    if (isDesktop)
                      SettingsTile.switchTile(
                          title: Text(
                            "Start with system".tr,
                            style: textStyle,
                          ),
                          initialValue:
                              Get.find<AutostartService>().isEnabled.value,
                          onToggle: (e) async {
                            if (e) {
                              Get.find<AutostartService>().enableAutostart();
                            } else {
                              Get.find<AutostartService>().disableAutostart();
                            }
                          }),
                    if (isDesktop)
                      SettingsTile.switchTile(
                          title: Text(
                            "Hide window when start fclash".tr,
                            style: textStyle,
                          ),
                          initialValue:
                              Get.find<ClashService>().isHideWindowWhenStart(),
                          onToggle: (e) async {
                            setState(() {
                              Get.find<ClashService>()
                                  .setHideWindowWhenStart(e);
                            });
                          }),
                  ])
            ]),
    );
  }

  void handleProxyMode() {
    Get.bottomSheet(BrnCommonActionSheet(
      actions: [
        BrnCommonActionSheetItem('direct'.tr),
        BrnCommonActionSheetItem('rule'.tr),
        BrnCommonActionSheetItem('global'.tr),
      ],
      onItemClickInterceptor: (index, s) {
        switch (index) {
          case 0:
            Get.find<ClashService>().changeConfigField('mode', 'Direct');
            break;
          case 1:
            Get.find<ClashService>().changeConfigField('mode', 'Rule');
            break;
          case 2:
            Get.find<ClashService>().changeConfigField('mode', 'Global');
            break;
        }
        return false;
      },
    ));
  }
}
