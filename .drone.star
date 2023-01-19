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
            publish_docker(),
        ],
    }

def publish_docker():
    return {
        'name': 'publish',
        'image': 'plugins/docker',
        'settings': {
            'repo': 'adonagy/mina',
            'tags': ['cluster-daily'],
            'dockerfile': 'dockerfiles/Dockerfile-mina-daemon',
            'username': {
                'from_secret': 'docker_hub_username',
            },
            'password': {
                'from_secret': 'docker_hub_password'
            },
            'dry_run': 'true',
        },
    }

def trigger_on_branch(branch):
    return {
        'branch': [
            branch
        ],
    }