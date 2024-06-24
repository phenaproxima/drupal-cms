<?php

declare(strict_types=1);

namespace Drupal\starshot_installer;

use Composer\Json\JsonFile;
use Composer\Script\Event;
use Composer\Util\Platform;
use Drupal\Component\Serialization\Yaml;

/**
 * Contains Composer scripts used during Starshot installation.
 */
final class ScriptHandler {

  /**
   * Sets the WEB_ROOT environment variable, optionally changing the web root.
   *
   * @param \Composer\Script\Event $event
   *   The event object.
   */
  public static function webRoot(Event $event): void {
    $extra = $event->getComposer()->getPackage()->getExtra();
    $old_root = $new_root = $extra['drupal-scaffold']['locations']['web-root'];

    // If a new web root was passed, update `composer.json`.
    $arguments = $event->getArguments();
    if ($arguments) {
      assert(str_ends_with($old_root, '/'));
      $new_root = rtrim($arguments[0], '/');

      $file = new JsonFile('composer.json');
      $data = $file->read();

      $data['extra']['drupal-scaffold']['locations']['web-root'] = "$new_root/";

      $installer_paths = preg_replace(
        "|^$old_root|",
        $data['extra']['drupal-scaffold']['locations']['web-root'],
        array_keys($extra['installer-paths']),
      );
      $data['extra']['installer-paths'] = array_combine($installer_paths, $extra['installer-paths']);

      $file->write($data);
    }
    Platform::putEnv('WEB_ROOT', $new_root);
  }

  /**
   * Writes Drush configuration for installing Starshot.
   *
   * @param \Composer\Script\Event $event
   *   The event object.
   */
  public static function configureDrush(Event $event): void {
    // If DDEV is managing site settings, it's probably already set up the
    // database, so we don't need to do anything else here.
    if (getenv('IS_DDEV_PROJECT') && file_exists('web/sites/default/settings.ddev.php')) {
      return;
    }
    $data = [];
    $arguments = $event->getArguments();

    // If SQLite is available, use a SQLite database by default. Otherwise,
    // Drush will prompt for a database URL during installation.
    if (extension_loaded('pdo_sqlite')) {
      $arguments[0] ??= 'sqlite://db.sqlite';
    }
    if ($arguments) {
      $data['command']['site']['install']['options']['db-url'] = $arguments[0];
    }
    file_put_contents('drush-install.yml', Yaml::encode($data));
  }

}
