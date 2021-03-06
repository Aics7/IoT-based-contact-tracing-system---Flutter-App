package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    flutterEngine.getPlugins().add(new me.carda.awesome_notifications.AwesomeNotificationsPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.deviceinfo.DeviceInfoPlugin());
      com.flutter.text_to_speech.FlutterTextToSpeechPlugin.registerWith(shimPluginRegistry.registrarFor("com.flutter.text_to_speech.FlutterTextToSpeechPlugin"));
      io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin.registerWith(shimPluginRegistry.registrarFor("io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin"));
    flutterEngine.getPlugins().add(new app.loup.geolocation.GeolocationPlugin());
    flutterEngine.getPlugins().add(new com.baseflow.location_permissions.LocationPermissionsPlugin());
    flutterEngine.getPlugins().add(new app.loup.streams_channel.StreamsChannelPlugin());
  }
}
