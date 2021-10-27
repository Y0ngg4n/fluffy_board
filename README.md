<div align="center">
  <p><img src="https://cdn.oblivioncoding.pro/fluffy_board/AppLogo.png" height="200" alt="Logo"></p>
  <h1>Fluffyboard</h1>
  <p>Fluffyboard is a open source, free and self-hostable Whiteboard Application</p>
  <p>Test the <a href="https://fluffyboard.obco.pro/">demonstration</a> of Fluffyboard</p>
  <p>
    <a href='https://play.google.com/store/apps/details?id=pro.oblivioncoding.fluffy_board'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' height="100"></a>
    <a href='https://f-droid.org/packages/pro.oblivioncoding.fluffy_board/'><img alt='Get it on F-Droid' src='https://fdroid.gitlab.io/artwork/badge/get-it-on.png' height="100"></a>
  </p>
  <p>
    <img src="https://img.shields.io/docker/cloud/automated/yonggan/fluffy_board-web" alt="Docker Cloud Automated build" height="50">
    <img src="https://img.shields.io/docker/cloud/build/yonggan/fluffy_board-web" alt="Docker Cloud Build Status" height="50">
    <img alt="GitHub tag (latest SemVer)" src="https://img.shields.io/github/v/tag/Y0ngg4n/fluffy_board" height="50">
    <img alt="GitHub language count" src="https://img.shields.io/github/languages/count/Y0ngg4n/fluffy_board" height="50">
    <img alt="GitHub" src="https://img.shields.io/github/license/Y0ngg4n/fluffy_board" height="50">
    <a href="https://github.com/Y0ngg4n/fluffy_board/actions/workflows/dockerhub.yaml"><img alt="Push to Dockerhub" src="https://github.com/Y0ngg4n/fluffy_board/actions/workflows/dockerhub.yaml/badge.svg" height="50"></a>
  </p>
</div>

Table of Contents
-----------------

1. [Features](#features)
2. [Installation](#installation)
3. [Roadmap](#roadmap)
4. [Contributing](#contributing)
5. [License](#license)

Features
--------

- _Online_ Whiteboards
- _Offline_ Whiteboards
- Downloading and Uploading Whiteboards
- Import and Export Whiteboards
- Organizing Whiteboards in Folders
- Sharing online Whiteboards with readonly and write Permissions
- Drawing lines
- Highlighting
- Drawing Straight Lines and Arrows
- Drawing Rects, Triangles and Circles
- Adding Text
- Uploading Images
- Importing PDF
- Changing Background
- Settings sync
- Adding bookmarks
- Changing Toolbar location

Installation
------------

### Web instance

For the [Docker image](https://hub.docker.com/repository/docker/yonggan/fluffy_board-web/) see more on DockerHub.

To set up your own web instance visit the <a href="Repository">Fluffy REST API Repository</a>.

### Windows

Download the `Fluffyboard-windows.zip` from the [latest Release](https://github.com/Y0ngg4n/fluffy_board/releases).

Extract the zip archive and place it's contents in the folder of your choice.

### Linux

Download the `Fluffyboard-linux.zip` from the [latest Release](https://github.com/Y0ngg4n/fluffy_board/releases).

Extract the zip archive and and place it's contents in the folder of your choice.

Give the executable the required permissions.

```terminal
chmod +x fluffy_board
```

Create a *symbolic link* to the executable in `/usr/local/bin/`.

```sh
sudo ln -s /home/USERNAME/PATH/TO/EXECUTABLE /usr/local/bin/fluffyboard
```

### macOS

Download the `Fluffyboard-mac.zip` from the [latest Release](https://github.com/Y0ngg4n/fluffy_board/releases).

Extract the zip archive and and place it's contents in the folder of your choice.

Give the executable the required permissions.

```sh
chmod +x fluffy_board.app
```

You can now find ***Fluffyboard*** in `Finder`.

Roadmap
-------

You can find the [current roadmap](https://github.com/Y0ngg4n/fluffy_board/projects/2) in `Projects`.

<h2 id="Contributing">Contributing</h2>

Contributions are always welcome!

License
-------

***Fluffyboard*** is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).
