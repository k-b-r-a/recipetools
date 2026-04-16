<h1 align="center" style="font-size:28px; line-height:1"><b>Recipetools</b></h1>

<div align="center">
  <a href="">
    <img alt="Icon" src="promotional/icons/icon.png" width="150px" >
  </a>
</div>

<a href="">
  <div align="center">
    <img width="95%" src="promotional/GitHub/SocialPreviewGitHub.png" alt="Promo banner">
  </div>
</a>

<br />

## ✨ Key Features

- **Smart Ingredient Scaling:** Automatically calculate and adjust grams and measurements when changing portion sizes or specific baking molds.
- **Cost & Margin Tracking:** Input ingredient costs to accurately estimate prices and track profit margins for your dessert and culinary products.
- **Collaborative Sync:** Share your recipe database and business calculations with collaborators seamlessly across devices.
- **Offline First:** Guaranteed access to all your recipes without an internet connection, powered by a local Drift database.

## 🛠️ Built With

- **Flutter** - Cross-platform UI Framework
- **Dart** - Primary Language
- **Drift (SQL)** - Local Database Management
- **Firebase** - Authentication & Cloud Sync

---

### 📝 Changelog

Changes and progress about development is all heavily documented in GitHub [commits](https://github.com/k-b-r-a/recipes_tools/commits/main/)

### 🌍 Translations

The translations are available here: https://docs.google.com/spreadsheets/d/1URmpVdxm1Eb4_hpAHPuT58OKXW6qobx2y4XevcXxxyQ/edit?usp=sharing. If you would like to help translate, please reach out on email: kbradevp@gmail.com

### 💻 Developer Notes

### Pull Requests and Contributions

This project is currently closed to outside code contributions to maintain clear licensing and commercial rights. However, bug reports and feature requests via the [Issues](https://github.com/k-b-r-a/recipes_tools/issues) tab are highly encouraged!

### Android Release

- To build an app-bundle Android release, run `flutter build appbundle --release`

Note: required Android SDK.

### iOS Release

- To build an IPA iOS release, run `flutter build ipa`

Note: requires MacOS.

### Firebase Deployment

- To deploy to firebase, run `firebase deploy`

Note: required Firebase.

### GitHub release

- Create a tag for the current version specified in `pubspec.yaml`
- `git tag <version>`
- Push the tag
- `git push origin <version>`
- Create the release and upload binaries
- https://github.com/k-b-r-a/recipes_tools/releases/new
