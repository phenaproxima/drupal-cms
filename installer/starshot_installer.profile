<?php

declare(strict_types=1);

use Drupal\Component\Plugin\ConfigurableInterface;
use Drupal\Core\Batch\BatchBuilder;
use Drupal\Core\Extension\ModuleInstallerInterface;
use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\Recipe\Recipe;
use Drupal\Core\Recipe\RecipeRunner;
use Drupal\geocoder\Entity\GeocoderProvider;
use Symfony\Component\Process\ExecutableFinder;

/**
 * Implements hook_install_tasks().
 */
function starshot_installer_install_tasks(): array {
  return [
    'starshot_installer_apply_recipes' => [
      'type' => 'batch',
      'display_name' => t('Apply recipes'),
    ],
    'starshot_installer_configure_geocoder' => [
    ],
    'starshot_installer_uninstall_myself' => [
      // As a final task, this profile should uninstall itself.
    ],
  ];
}

/**
 * Implements hook_form_alter() for install_settings_form.
 *
 * @see \Drupal\Core\Installer\Form\SiteSettingsForm
 */
function starshot_installer_form_install_settings_form_alter(array &$form): void {
  // Default to SQLite, if available, because it doesn't require any additional
  // configuration.
  $sqlite = 'Drupal\sqlite\Driver\Database\sqlite';
  if (array_key_exists($sqlite, $form['driver']['#options']) && extension_loaded('pdo_sqlite')) {
    $form['driver']['#default_value'] = $sqlite;
  }
}

/**
 * Implements hook_form_alter() for install_configure_form.
 */
function starshot_installer_form_install_configure_form_alter(array &$form): void {
  ['composer' => $composer, 'rsync' => $rsync] = \Drupal::configFactory()
    ->get('package_manager.settings')
    ->get('executables');

  $finder = new ExecutableFinder();
  $finder->addSuffix('.phar');
  $composer ??= $finder->find('composer');
  $rsync ??= $finder->find('rsync');

  $form['package_manager'] = [
    '#type' => 'fieldset',
    '#title' => t('Package Manager settings (advanced)'),
    '#description' => t("To install extensions in the administrative interface, Drupal needs to know where Composer and <code>rsync</code> are. This will be auto-detected if possible. If you leave these blank, you can still browse for extensions but you'll need to use the command line to install them."),
  ];
  $form['package_manager']['composer'] = [
    '#type' => 'textfield',
    '#title' => t('Full path to <code>composer</code> or <code>composer.phar</code>'),
    '#default_value' => $composer,
  ];
  $form['package_manager']['rsync'] = [
    '#type' => 'textfield',
    '#title' => t('Full path to <code>rsync</code>'),
    '#default_value' => $rsync,
  ];
  $form['#submit'][] = '_starshot_installer_install_configure_form_submit';
}

/**
 * Submit callback for install_configure_form.
 *
 * Sets the full paths to Composer and rsync, if available, and enables
 * installing projects via the Project Browser UI.
 */
function _starshot_installer_install_configure_form_submit(array &$form, FormStateInterface $form_state): void {
  $composer = $form_state->getValue('composer');
  $rsync = $form_state->getValue('rsync');

  if ($composer && $rsync) {
    \Drupal::configFactory()
      ->getEditable('package_manager.settings')
      ->set('executables', [
        'composer' => $composer,
        'rsync' => $rsync,
      ])
      ->save();

    \Drupal::configFactory()
      ->getEditable('project_browser.admin_settings')
      ->set('allow_ui_install', TRUE)
      ->save();
  }
}

/**
 * Runs a batch job that applies all of the Starshot recipes.
 *
 * @return array
 *   The batch job definition.
 */
function starshot_installer_apply_recipes(): array {
  $batch = new BatchBuilder();
  $batch->setTitle(t('Applying recipes'));

  $recipe = Recipe::createFromDirectory(\Drupal::root() . '/recipes/starshot');

  foreach (RecipeRunner::toBatchOperations($recipe) as [$callback, $arguments]) {
    $batch->addOperation($callback, $arguments);
  }
  return $batch->toArray();
}

function starshot_installer_configure_geocoder(): void {
  /** @var \Drupal\geocoder\GeocoderProviderInterface $provider */
  $provider = GeocoderProvider::load('nominatim');
  $plugin = $provider->getPlugin();
  if ($plugin instanceof ConfigurableInterface) {
    $uuid = \Drupal::config('system.site')->get('uuid');
    $configuration = $plugin->getConfiguration();
    $configuration['userAgent'] = "Drupal $uuid";
    $configuration['referer'] = "http://drupal-$uuid.local";
    $plugin->setConfiguration($configuration);
  }
  $provider->save();
}

/**
 * Uninstalls this install profile, as a final step.
 */
function starshot_installer_uninstall_myself(): void {
  \Drupal::service(ModuleInstallerInterface::class)->uninstall([
    'starshot_installer',
  ]);
}
