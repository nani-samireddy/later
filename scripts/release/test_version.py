import unittest
from version import parse, validate

class VersionTests(unittest.TestCase):
    def test_candidates_and_stable(self):
        self.assertEqual(validate('android-v1.0.0-rc.2+3', ['android-v1.0.0-rc.1+2']), ('1.0.0-rc.2', 3))
        self.assertEqual(validate('android-v1.0.0+4', ['android-v1.0.0-rc.2+3']), ('1.0.0', 4))
    def test_reject_reuse_downgrade_and_invalid_tags(self):
        for tag, previous in [('android-v1.0.1+2', 'android-v1.0.0+2'), ('android-v1.0.0-rc.2+5', 'android-v1.0.0+4'), ('android-v0.9.0+5', 'android-v1.0.0+4')]:
            with self.assertRaises(ValueError): validate(tag, [previous])
        for tag in ['v1.0.0', 'android-v01.0.0+2', 'android-v1.0.0+2100000001', 'android-v1.0.0-rc.0+2']:
            with self.assertRaises(ValueError): parse(tag)

if __name__ == '__main__': unittest.main()
