import '../../i18n/strings.g.dart';
import '../../logic/cubits/event_cubit.dart';

/// Translates a region code to a display label.
/// Converts [kAbroadRegionKey] to the localized "Abroad" string,
/// passes other region names through unchanged.
String regionLabel(String region) =>
    region == kAbroadRegionKey ? t.events.filter.abroad : region;
