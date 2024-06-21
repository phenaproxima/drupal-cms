![build status](https://github.com/phenaproxima/starshot-prototype/actions/workflows/main.yml/badge.svg)

**This is an experimental prototype. Don't use it for production sites!**

## Drupal Starshot
Starshot is Drupal 10, but supercharged with some of the best modules and themes out there, set up in useful ways to help you get started building a site right away. Starshot is built on the [Drupal recipe system](https://drupal.org/project/distributions_recipes), so it doesn't lock you in like a normal distribution would.

[![button.png](.tugboat%2Fbutton.png)](https://main-fw6eaiqwuojqnlnerzwoc8rf2ca8t4qq.tugboatqa.com/)

[Learn more about Starshot on drupal.org.](https://drupal.org/starshot)

<hr/>

* [Installation](#installation)
* [Whom this is for](#whom-this-is-for)
* [What this gets you](#what-this-gets-you)
* [How this is different from a distribution](#how-this-is-different-from-a-distribution)
* [Included modules and themes](#included-modules-and-themes)
* [How we choose which modules and themes to include](#how-we-choose-which-modules-and-themes-to-include)
* [Known issues & workarounds](#known-issues--workarounds)

## Installation
```
composer create-project drupal/starshot-project --repository='{"type":"vcs","url":"https://github.com/phenaproxima/starshot-prototype"}' --stability=dev
```
This one command will install Starshot and open it in a web browser for you to play with. You'll get all the modules and themes listed below, pre-configured.

If you use [DDEV](https://ddev.com), you can get Starshot up and running with this:
```
git clone https://github.com/phenaproxima/starshot-prototype.git starshot
cd starshot && ddev install
```
You'll need DDEV 1.23.0 or later. [See the documentation](https://ddev.readthedocs.io/en/stable/users/install/ddev-upgrade/) if you need to upgrade.

If you use [Lando](https://lando.dev/), you can get Starshot up and running with this:
```
git clone https://github.com/phenaproxima/starshot-prototype.git starshot
cd starshot
lando start && lando drupal:install
```

## Whom this is for
Anyone who wants to create a website with Drupal, but doesn't want to build it -- including the authoring experience -- from the ground up using the relatively bare-bones tools provided by Drupal core. You need extra modules to get the most out of Drupal, but it can be hard to know how to start.

Starshot's purpose is to get you going with the most useful tools favored by the Drupal community, as quickly and easily as possible.

## What this gets you
* Useful content types, already set up for translation, meta tags, pretty URLs, moderation, and scheduling.
* A standard set of media types, with some enhancements (setting an image's focal point, for example, or better linking to uploaded documents).
* An amazingly full-featured platform for building web forms with anti-spam protection.
* A much nicer administrative experience than you'd get with plain Drupal, based on the Gin theme, plus the Navigation and Coffee modules.
* Basic niceties:
  * An XML site map
  * Better date and time fields
  * The ability to set up redirects
  * Better handling of files on disk
  * The ability to clone content
  * Comparing different versions of content
* Some sample content, so you're not starting from nothing.

## How this is different from a distribution
Distributions are based on install profiles, and therefore have a lock-in effect. If you start a site on a distribution, you can't really stop using that distribution -- at least, not easily. Starshot uses recipes to give you a strong starting point, but there is no lock-in.

We don't _quite_ support this yet, but you'll also be able to use Starshot's components on an _existing_ site too. That's the power of recipes!

## Included modules and themes
* [Address](https://drupal.org/project/address)
* [Antibot](https://drupal.org/project/antibot)
* [Coffee](https://drupal.org/project/coffee)
* [Diff](https://drupal.org/project/diff)
* [Easy Breadcrumb](https://www.drupal.org/project/easy_breadcrumb)
* [Focal Point](https://drupal.org/project/focal_point)
* [Geolocation Field](https://drupal.org/project/geolocation)
* [Gin](https://drupal.org/project/gin)
* [Gin Toolbar](https://drupal.org/project/gin_toolbar)
* [Honeypot](https://drupal.org/project/honeypot)
* [Linkit](https://drupal.org/project/linkit)
* [Media Entity Download](https://drupal.org/project/media_entity_download)
* [Media File Delete](https://drupal.org/project/media_file_delete)
* [Metatag](https://drupal.org/project/metatag)
* [Pathauto](https://drupal.org/project/pathauto)
* [Quick Node Clone](https://drupal.org/project/quick_node_clone)
* [Redirect](https://drupal.org/project/redirect)
* [Simple Add More](https://drupal.org/project/sam)
* [Scheduler](https://drupal.org/project/scheduler)
* [Simple Sitemap](https://drupal.org/project/simple_sitemap)
* [Smart Date](https://drupal.org/project/smart_date)
* [Type Tray](https://drupal.org/project/type_tray)
* [ULI Custom Workflow](https://drupal.org/project/uli_custom_workflow)
* [Webform](https://drupal.org/project/webform)

...and, of course, [Drush](https://www.drush.org).

## How we choose which modules and themes to include
Right now it's pretty much "let's add whatever we think is useful for most people". [We're working on defining a policy and process for this.](https://github.com/phenaproxima/starshot-prototype/issues/11) If you have an idea for a module to include, by all means [open an issue](https://github.com/phenaproxima/starshot-prototype/issues/new/choose)!

## Known issues & workarounds

### Server timeout
Some users might experience a timeout after logging into Starshot, particularly when the PHP web server remains idle for some time.

You may see an error like this:
```
The process "test -n "$CI" || composer drupal:run-server" exceeded the timeout of 300 seconds.
```
If you encounter this, you can restart the server using the following command:
```
composer drupal:run-server
```

### Error: SQLSTATE[HY000]: General error: 11 database disk image is malformed
If you're using **DDEV with Docker Desktop on a Mac**, you might see the following error:
```
SQLSTATE[HY000]: General error: 11 database disk image is malformed`
```
This is caused by the way files are shared between your Mac and Docker, which is set to `VirtioFS`. To fix it, change the file sharing method to either `gRPC FUSE` or `osxfs (Legacy)`:

- [Open the Docker Desktop settings](https://docs.docker.com/desktop/settings/mac/).
- Look for the "General" tab, and find the option for file sharing implementation.
- Choose either `gRPC FUSE` or `osxfs (Legacy)` from the available options.
- Click on **Apply & Restart** Docker.

### Using Project Browser with DDEV
If you're using DDEV, prefix the terminal commands suggested by Project Browser with `ddev exec`.
