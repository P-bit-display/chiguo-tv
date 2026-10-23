import hashlib
import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('prepare', ROOT / 'tools/prepare_tvbox.py')
prepare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepare)


class BundleTests(unittest.TestCase):
    def test_changed_video_id_is_patched_only_after_matching_source_hash(self):
        original = ('prefix ' + prepare.OLD_ID + ' suffix').encode()
        fixed = ('prefix ' + prepare.NEW_ID + ' suffix').encode()
        entry = {'path': 'js/网易公版影像.js', 'local_fix': True,
                 'source_sha256': prepare.digest(original), 'sha256': prepare.digest(fixed)}
        self.assertEqual(prepare.checked_asset(original, entry), fixed)
        self.assertEqual(prepare.checked_asset(fixed, entry), fixed)
        with self.assertRaises(ValueError):
            prepare.checked_asset(b'changed upstream data', entry)

    def test_paths_cannot_leave_bundle(self):
        for value in ('../private', '/private', 'js/../../private', 'js//file', 'js/./file', 'js\\file'):
            with self.subTest(value=value), self.assertRaises(ValueError):
                prepare.safe_path(value)

    def test_localization_preserves_unknown_and_external_resources(self):
        commit = 'a' * 40
        source = {'api': f'https://raw.githubusercontent.com/qist/tvbox/{commit}/lib/a.js',
                  'ext': 'https://example.com/source.json',
                  'missing': f'https://raw.githubusercontent.com/qist/tvbox/{commit}/js/missing.js'}
        result = prepare.localize(source, {'lib/a.js'}, commit)
        self.assertEqual(result['api'], prepare.LOCAL_BASE + 'lib/a.js')
        self.assertEqual(result['ext'], source['ext'])
        self.assertEqual(result['missing'], source['missing'])

    def test_cache_symlinks_cannot_read_outside_cache(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            cache = root / 'cache'
            cache.mkdir()
            secret = root / 'outside'
            secret.write_bytes(b'outside')
            (cache / 'file').symlink_to(secret)
            with self.assertRaises(ValueError):
                prepare.obtain({'path': 'file', 'sha256': prepare.digest(b'outside')}, 'a' * 40, cache)


if __name__ == '__main__':
    unittest.main()
