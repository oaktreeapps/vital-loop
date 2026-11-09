// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in THIRD_PARTY_NOTICES.md.
//
// Adapted by Oaktreeapps in 2026 from genui's basic catalog, for A2UI v1.0
// and a2ui_flutter.

import 'package:flutter/material.dart';

import '../shared/catalog_item.dart';
import '../shared/data_binding.dart';
import 'basic_schemas.dart';

/// The icons the Icon component can show, by name.
enum AvailableIcons {
  /// The "account circle" icon.
  accountCircle(Icons.account_circle),

  /// The "add" icon.
  add(Icons.add),

  /// The "arrow back" icon.
  arrowBack(Icons.arrow_back),

  /// The "arrow forward" icon.
  arrowForward(Icons.arrow_forward),

  /// The "attach file" icon.
  attachFile(Icons.attach_file),

  /// The "calendar today" icon.
  calendarToday(Icons.calendar_today),

  /// The "call" icon.
  call(Icons.call),

  /// The "camera" icon.
  camera(Icons.camera_alt),

  /// The "check" icon.
  check(Icons.check),

  /// The "close" icon.
  close(Icons.close),

  /// The "delete" icon.
  delete(Icons.delete),

  /// The "download" icon.
  download(Icons.download),

  /// The "edit" icon.
  edit(Icons.edit),

  /// The "error" icon.
  error(Icons.error),

  /// The "event" icon.
  event(Icons.event),

  /// The "favorite" icon.
  favorite(Icons.favorite),

  /// The "favorite off" icon.
  favoriteOff(Icons.favorite_outline),

  /// The "folder" icon.
  folder(Icons.folder),

  /// The "help" icon.
  help(Icons.help),

  /// The "home" icon.
  home(Icons.home),

  /// The "info" icon.
  info(Icons.info_outline),

  /// The "location on" icon.
  locationOn(Icons.location_on),

  /// The "lock" icon.
  lock(Icons.lock_outline),

  /// The "lock open" icon.
  lockOpen(Icons.lock_open_outlined),

  /// The "mail" icon.
  mail(Icons.mail_outline),

  /// The "menu" icon.
  menu(Icons.menu),

  /// The "more horiz" icon.
  moreHoriz(Icons.more_horiz),

  /// The "more vert" icon.
  moreVert(Icons.more_vert),

  /// The "notifications" icon.
  notifications(Icons.notifications),

  /// The "notifications off" icon.
  notificationsOff(Icons.notifications_none),

  /// The "payment" icon.
  payment(Icons.payment),

  /// The "person" icon.
  person(Icons.person),

  /// The "phone" icon.
  phone(Icons.phone),

  /// The "photo" icon.
  photo(Icons.photo),

  /// The "print" icon.
  print(Icons.print),

  /// The "refresh" icon.
  refresh(Icons.refresh),

  /// The "search" icon.
  search(Icons.search),

  /// The "send" icon.
  send(Icons.send),

  /// The "settings" icon.
  settings(Icons.settings),

  /// The "share" icon.
  share(Icons.share),

  /// The "shopping cart" icon.
  shoppingCart(Icons.shopping_cart),

  /// The "star" icon.
  star(Icons.star),

  /// The "star half" icon.
  starHalf(Icons.star_half_outlined),

  /// The "star off" icon.
  starOff(Icons.star_outline),

  /// The "upload" icon.
  upload(Icons.upload),

  /// The "visibility" icon.
  visibility(Icons.visibility),

  /// The "visibility off" icon.
  visibilityOff(Icons.visibility_off),

  /// The "warning" icon.
  warning(Icons.warning);

  const AvailableIcons(this.iconData);

  /// The Material icon drawn for this name.
  final IconData iconData;

  /// The icon named [name], or `null` if there is none.
  static AvailableIcons? fromName(String name) {
    for (final AvailableIcons icon in AvailableIcons.values) {
      if (icon.name == name) return icon;
    }
    return null;
  }
}

/// Shows one of the [AvailableIcons]; an unknown name shows a broken-image
/// icon. `name` may be a literal or a data-model binding.
final CatalogItem icon = CatalogItem(
  name: 'Icon',
  description: 'Displays an icon from a set of available icons.',
  schemaIsComplete: true,
  dataSchema: basicSchema('Icon'),
  widgetBuilder: (itemContext) => BoundString(
    dataContext: itemContext.dataContext,
    value: itemContext.data['name'],
    builder: (context, String? currentValue) => Icon(
      AvailableIcons.fromName(currentValue ?? '')?.iconData ??
          Icons.broken_image,
    ),
  ),
  exampleData: [
    () => '''
      [
        {"id": "root", "component": "Icon", "name": "add"}
      ]
    ''',
  ],
);
