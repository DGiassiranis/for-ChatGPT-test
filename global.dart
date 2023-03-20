/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:get_it/get_it.dart';

import 'classes/app.dart';

GetIt global = GetIt.instance;

Future<void> globalSetup() async {
  NotebarsApp app = NotebarsApp();
  global.registerSingleton<NotebarsApp>(app);

  await app.start();
}

NotebarsApp get app => global.get<NotebarsApp>();
