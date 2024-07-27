import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/proxy.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClashContainer extends StatefulWidget {
  final Widget child;

  const ClashContainer({
    super.key,
    required this.child,
  });

  @override
  State<ClashContainer> createState() => _ClashContainerState();
}

class _ClashContainerState extends State<ClashContainer>
    with AppMessageListener {

  Widget _updateCoreState(Widget child) {
    return Selector2<Config, ClashConfig, CoreState>(
      selector: (_, config, clashConfig) => CoreState(
        accessControl: config.isAccessControl ? config.accessControl : null,
        allowBypass: config.allowBypass,
        systemProxy: config.systemProxy,
        mixedPort: clashConfig.mixedPort,
        onlyProxy: config.onlyProxy,
      ),
      builder: (__, state, child) {
        clashCore.setState(state);
        return child!;
      },
      child: child,
    );
  }

  Widget _updateCheckIpNum(Widget child){
    return Selector2<AppState, Config, CheckIpSelectorState>(
      selector: (_, appState, config) {
        return CheckIpSelectorState(
          selectedMap: appState.selectedMap,
        );
      },
      builder: (_, state, child) {
        globalState.appController.addCheckIpNumDebounce();
        return child!;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _updateCheckIpNum(_updateCoreState(widget.child));
  }

  @override
  void initState() {
    super.initState();
    clashMessage.addListener(this);
  }

  @override
  Future<void> dispose() async {
    clashMessage.removeListener(this);
    super.dispose();
  }

  @override
  void onDelay(Delay delay) {
    final appController = globalState.appController;
    appController.setDelay(delay);
    super.onDelay(delay);
  }

  @override
  void onLog(Log log) {
    globalState.appController.appState.addLog(log);
    super.onLog(log);
  }

  @override
  void onRequest(Connection connection) async {
    globalState.appController.appState.addRequest(connection);
    super.onRequest(connection);
  }

  @override
  void onLoaded(String groupName) {
    final appController = globalState.appController;
    final currentSelectedMap = appController.config.currentSelectedMap;
    final proxyName = currentSelectedMap[groupName];
    if (proxyName == null) return;
    globalState.changeProxy(
      config: appController.config,
      groupName: groupName,
      proxyName: proxyName,
    );
    appController.addCheckIpNumDebounce();
    super.onLoaded(proxyName);
  }

  @override
  void onStarted(String runTime) {
    super.onStarted(runTime);
    proxy?.updateStartTime();
    final appController = globalState.appController;
    appController.applyProfile(isPrue: true).then((_) {
      appController.addCheckIpNumDebounce();
    });
  }
}
