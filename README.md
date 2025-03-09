# Visual Studio Code SOF Workspace

This repository is a vscode workspace for SOF developers. It contains useful task integrations for common SOF build targets alongside useful extensions that support the multiple different programming languages used in SOF.

## Installation

This repository should be cloned into your SOF workspace directory:

```bash
~/work/sof
```

As this is an optional repository, most developers may already have the workspace set up meaning a clone and copy of this repo will be needed otherwise a clone and rename will be required for new developers.

### Clone and Copy

Existing developers should clone and then

```bash
cp -ap vscode-workspace/.git* ~/work/sof
cd ~/work/sof
git checkout main
git reset HEAD --hard
```

At this point the original cloned repo can be deleted and git will now track the workspace repository.

### Clone and Rename

New developers can simply clone and rename the repository

```bash
mv vscode-workspace ~/work/sof
```

### Usage

Once the workspace is created, please restart vscode and open the workspace. At this point you will be prompted to install the extensions.

Common tasks can then be exexcuted via the "Terminal -> Run Task" menu.
