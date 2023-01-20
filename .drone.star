def main(ctx):
    return [
        pipeline(),
    ]

def pipeline():
    return {
        'kind': 'pipeline',
        'type': 'docker',
        'name': 'publish-docker-image',
        'trigger': trigger_on_branch('release/2.0.0-drone'),
        'steps': [
            clone_mina_step('release/2.0.0'),
            build_docker('build-deps', './dockerfiles/stages/1-build-deps'),
            build_docker('opam-deps', './dockerfiles/stages/2-opam-deps', build_args=['MINA_BRANCH=release/2.0.0']),
            publish_docker('mina',  './dockerfiles/stages/3-builder', build_args=['MINA_BRANCH=release/2.0.0']),
        ],
        'clone': disable_clone(),
    }

def disable_clone():
    return {
        'disable': True,
    }

def clone_mina_step(branch):
    return {
        'name': 'clone',
        'image': 'alpine/git',
        'commands': [
            'git clone https://github.com/MinaProtocol/mina.git .',
            'git checkout ' + branch,
        ]
    }

def build_docker(name, dockerfile, build_args=[]):
    return {
        'name': name,
        'image': 'plugins/docker',
        'settings': {
            'repo': name,
            'dockerfile': dockerfile,
            'dry_run': True,
            'build_args': build_args,
        },
    }

def publish_docker(name, dockerfile, build_args=[]):
    return {
        'name': 'publish' + name,
        'image': 'plugins/docker',
        'settings': {
            'repo': 'adonagy/mina',
            'tags': ['cluster-daily'],
            'dockerfile': dockerfile,
            'username': {
                'from_secret': 'docker_hub_username',
            },
            'password': {
                'from_secret': 'docker_hub_password'
            },
            'dry_run': True,
            'build_args': build_args,
        },
    }

def trigger_on_branch(branch):
    return {
        'branch': [
            branch
        ],
    }