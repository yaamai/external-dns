TARGET_ARCH_LIST = ["amd64", "arm64", "arm"]

def main(ctx):
  pipeline_list = []
  pipeline_list.extend([pipeline(arch) for arch in TARGET_ARCH_LIST])
  pipeline_list.append(docker_manifest())
  return pipeline_list

def pipeline(arch):
  return {
    "kind": "pipeline",
    "type": "docker",
    "name": "default-" + arch,
    "platform": {
      "arch": arch
    },
    "steps": [
      {
        "name": "image-build",
        "image": "plugins/docker",
        "settings": {
          "username": {
            "from_secret": "docker_username"
          },
          "password": {
            "from_secret": "docker_password"
          },
          "repo": "yaamai/external-dns",
          "auto_tag": True,
          "auto_tag_suffix": "${DRONE_STAGE_ARCH}"
        }
      }
    ]
  }

def docker_manifest():
  return {
    "kind": "pipeline",
    "type": "docker",
    "name": "manifest",
    "steps": [
      {
        "name": "push-manifest",
        "image": "plugins/manifest",
        "settings": {
          "username": {
            "from_secret": "docker_username"
          },
          "password": {
            "from_secret": "docker_password"
          },
          "target": "yaamai/external-dns:latest",
          "template": "yaamai/external-dns:ARCH",
          "platforms": [
            "linux/amd64",
            "linux/arm",
            "linux/arm64"
          ]
        }
      }
    ],
    "depends_on": ["default-" + arch for arch in TARGET_ARCH_LIST]
  }
