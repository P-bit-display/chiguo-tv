#!/usr/bin/env python3
"""Build a version-checked TVBox local bundle without contacting the TV."""
import argparse
import hashlib
import json
import re
import shutil
import tempfile
import urllib.error
import urllib.parse
import urllib.request
import zipfile
from pathlib import Path

OLD_ID = 'let vid = input.split("/view/")[1];'
NEW_ID = ('let match=input.match(/V[A-Z0-9]{8,}/i);'
          'if(!match){throw new Error("Missing NetEase video id");}'
          'let vid=match[0];')
LOCAL_BASE = 'http://127.0.0.1:9978/file/Download/ChiGuoTVBox_20261023/runtime/'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def safe_path(value):
    path = Path(value)
    if not value or '\\' in value or path.is_absolute() or any(
            part in ('', '.', '..') for part in value.split('/')):
        raise ValueError('Invalid bundle path')
    return path


def checked_asset(data, entry):
    if digest(data) == entry['sha256']:
        return data
    if digest(data) != entry.get('source_sha256', entry['sha256']):
        raise ValueError('SHA256 mismatch: ' + entry['path'])
    if entry.get('local_fix'):
        if entry['path'] != 'js/网易公版影像.js':
            raise ValueError('Unsupported local fix')
        text = data.decode('utf-8')
        if text.count(OLD_ID) != 1:
            raise ValueError('Upstream video-ID expression changed')
        data = text.replace(OLD_ID, NEW_ID).encode('utf-8')
    if digest(data) != entry['sha256']:
        raise ValueError('Output SHA256 mismatch: ' + entry['path'])
    return data


def fetch(url):
    request = urllib.request.Request(url, headers={'User-Agent': 'ChiGuo-TVBox-Bundle/1'})
    with urllib.request.urlopen(request, timeout=20) as response:
        # All expected assets are small scripts or JARs, never media files.
        data = response.read(16 * 1024 * 1024 + 1)
    if len(data) > 16 * 1024 * 1024:
        raise ValueError('Asset exceeds size limit')
    return data


def obtain(entry, commit, cache=None, plugin=False):
    relative = safe_path(entry['path'])
    if cache is not None:
        root = cache.resolve()
        target = (root / relative).resolve()
        if not target.is_relative_to(root):
            raise ValueError('Cache path escapes its directory')
        return checked_asset(target.read_bytes(), entry)
    source_path = entry['source_path'] if plugin else entry['path']
    safe_path(source_path)
    quoted = urllib.parse.quote(source_path, safe='/')
    urls = [f'https://raw.githubusercontent.com/qist/tvbox/{commit}/{quoted}',
            f'https://cdn.jsdelivr.net/gh/qist/tvbox@{commit}/{quoted}']
    failures = []
    for url in urls:
        try:
            return checked_asset(fetch(url), entry)
        except (OSError, ValueError, urllib.error.URLError) as error:
            failures.append(type(error).__name__)
    raise RuntimeError('Cannot obtain verified asset ' + entry['path'] + ': ' + ', '.join(failures))


def localize(value, cached, commit):
    if isinstance(value, dict):
        return {key: localize(item, cached, commit) for key, item in value.items()}
    if isinstance(value, list):
        return [localize(item, cached, commit) for item in value]
    if not isinstance(value, str):
        return value
    pattern = r'https://raw\.githubusercontent\.com/qist/tvbox/(?:' + commit + r'|master)/([^"\s\\]+)'
    def replace(match):
        path = urllib.parse.unquote(match.group(1))
        if path not in cached:
            return match.group(0)
        return LOCAL_BASE + urllib.parse.quote(path, safe='/')
    return re.sub(pattern, replace, value)


def build(repo, output, cache=None):
    manifest = json.loads((repo / 'tvbox/runtime-cache-manifest.json').read_text())
    commit = manifest['upstream_commit']
    if not re.fullmatch('[a-f0-9]{40}', commit):
        raise ValueError('Upstream commit must be pinned')
    if output.exists() and any(output.iterdir()):
        raise ValueError('Output directory must be empty; choose a new folder')
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='chiguo-bundle-', dir=output.parent) as directory:
        stage = Path(directory)
        cached = set()
        for entry in manifest['files']:
            relative = safe_path(entry['path'])
            data = obtain(entry, commit, cache / 'runtime' if cache else None)
            target = stage / 'runtime' / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            cached.add(entry['path'])
        upstream = json.loads((repo / 'tvbox/upstream.json').read_text())
        for plugin in upstream['plugins']:
            entry = {'path': plugin['file'], 'source_path': plugin['source_path'],
                     'sha256': plugin['sha256']}
            data = obtain(entry, commit, cache, plugin=True)
            target = stage / safe_path(plugin['file'])
            target.write_bytes(data)
            with zipfile.ZipFile(target) as archive:
                if archive.testzip() is not None:
                    raise ValueError('Invalid JAR archive')
        counts = {}
        for name in ('config-family.json', 'config-backup.json', 'config-simple.json'):
            config = json.loads((repo / 'tvbox' / name).read_text())
            config = localize(config, cached, commit)
            (stage / name).write_text(json.dumps(config, ensure_ascii=False, indent=2) + '\n')
            counts[name] = len(config['sites'])
        for source, destination in [('tvbox/live-local.json', 'live-local.json'),
                                    ('suzhou_mobile.txt', 'suzhou_mobile.txt'),
                                    ('suzhou_mobile.m3u', 'suzhou_mobile.m3u')]:
            shutil.copyfile(repo / source, stage / destination)
        (stage / 'build-info.json').write_text(json.dumps(
            {'upstream_commit': commit, 'runtime_files': len(cached), 'sites': counts}, indent=2) + '\n')
        if output.exists():
            output.rmdir()
        shutil.move(str(stage), str(output))
    return counts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True, help='New or empty output directory')
    parser.add_argument('--cache', type=Path, help='Existing complete local bundle for offline validation')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    try:
        counts = build(repo, args.output.resolve(), args.cache)
    except (OSError, ValueError, RuntimeError, KeyError, zipfile.BadZipFile) as error:
        parser.exit(1, 'Bundle preparation failed: ' + str(error) + '\n')
    print(json.dumps({'status': 'ready', 'sites': counts}, ensure_ascii=False))


if __name__ == '__main__':
    main()
