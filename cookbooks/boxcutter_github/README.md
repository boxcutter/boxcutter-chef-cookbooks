# boxcutter_github

Manages configuration for GitHub source control-related products.

## boxcutter_github::cli

Automated install of the GitHub CLI, or `gh`.

## boxcutter_github::runner

Automates install and configuration of GitHub self-hosted runners.

### Attributes
- node['boxcutter_github']['runners'][$ORG]
- node['boxcutter_github']['runners'][$ORG/$REPO]

### Usage

#### Runners


```ruby
node.default['boxcutter_github']['github_runner'] = {
  'runners' => {
    '/home/github-runner/actions-runner' => {
      'runner_name' => node['hostname'],
      'url' => 'https://github.com/boxcutter/oci',
      'owner' => 'github-runner',
      'group' => 'github-runner',
    }
  },
}
```

## Removing a runner

```
sudo su -
# Must run from runner root
cd /home/github-runner/actions-runner/latest
./svc.sh status

./svc.sh uninstall
```

```
su - github-runner
cd ~/actions-runner/latest
./config.sh remove
```
