<?php

namespace Drupal\Starshot\Drush\Commands;

use Consolidation\SiteAlias\SiteAliasManagerAwareTrait;
use Drupal\Core\Database\Database;
use Drupal\Core\DrupalKernelInterface;
use Drupal\Core\Site\SettingsEditor;
use Drush\Attributes as CLI;
use Drush\Boot\DrupalBootLevels;
use Drush\Commands\DrushCommands;
use Drush\SiteAlias\ProcessManager;
use Drush\SiteAlias\SiteAliasManagerAwareInterface;
use Psr\Container\ContainerInterface;

final class StarshotDrushCommands extends DrushCommands implements SiteAliasManagerAwareInterface {

  use SiteAliasManagerAwareTrait;

  private function __construct(private readonly DrupalKernelInterface $kernel) {
  }

  public static function create(ContainerInterface $container): self {
    return new static(
      $container->get(DrupalKernelInterface::class),
    );
  }

  /**
   * Adds a database connection to settings.php.
   */
  #[CLI\Command(name: 'sql:add-connection')]
  #[CLI\Bootstrap(DrupalBootLevels::CONFIGURATION)]
  #[CLI\Argument('db_url', 'A database connection URL.')]
  #[CLI\Argument('key', 'The database connection key.')]
  #[CLI\Option('target', 'The database connection target.')]
  public function addConnection(string $db_url, string $key, array $options = ['target' => 'default']): void {
    $alias = $this->siteAliasManager()->getSelf();

    $connection_info = Database::convertDbUrlToConnectionInfo($db_url, $alias->root());
    $settings = [
      'databases' => [
        $key => [
          $options['target'] => (object) [
            'value' => $connection_info,
            'required' => TRUE,
          ],
        ],
      ],
    ];

    assert($this->processManager instanceof ProcessManager);
    $driver = $connection_info['driver'];
    $this->processManager->drush($alias, 'pm:enable', [$driver], ['yes' => TRUE])
      ->mustRun();

    SettingsEditor::rewrite($this->kernel->getSitePath() . '/settings.php', $settings);
  }

}
