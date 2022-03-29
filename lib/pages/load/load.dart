import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/db/db.dart';
import 'package:piwigo/db/settings.dart';
import 'package:piwigo/environment.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/home/home.dart';
import 'package:piwigo/routes.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:ppg_ui/ppg_ui.dart';

class MyLoadPage extends StatefulWidget {
  const MyLoadPage({
    Key? key,
  }) : super(key: key);
  @override
  _MyLoadPageState createState() => _MyLoadPageState();
}

class _MyLoadPageState extends UIState<MyLoadPage> {
  dynamic _error;
  @override
  void initState() {
    super.initState();
    Future.value().then((value) => _init());
  }

  _init() async {
    aliveSetState(() {
      disabled = true;
      _error = null;
    });
    try {
      final id = await MySettings.instance.getAccount();
      checkAlive();
      final helper = (await DB.helpers).account;
      checkAlive();
      var account = await helper.getById(id);
      checkAlive();
      if (account != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MyHomePage(
              client: Client(
                baseUrl: account!.url,
                name: account.name,
                password: account.password,
              ),
            ),
          ),
        );
        return;
      }
      account = await helper.first();
      checkAlive();
      if (account != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MyHomePage(
              client: Client(
                baseUrl: account!.url,
                name: account.name,
                password: account.password,
              ),
            ),
          ),
        );
        return;
      }
      Navigator.of(context).pushReplacementNamed(MyRoutes.firstAdd);
    } catch (e) {
      aliveSetState(() {
        _error = e;
        disabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return const Scaffold(
        body: Center(
          child: SizedBox(
            height: 60,
            child: FittedBox(
              child: CupertinoActivityIndicator(),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(MyEnvironment.viewPadding),
        child: Text(
          '$_error',
          style: TextStyle(color: Theme.of(context).errorColor),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: S.of(context).app.refresh,
        child: const Icon(Icons.refresh),
        onPressed: _init,
      ),
    );
  }
}
