require 'spec_helper'

describe 'profiles::disk', type: :class do
  context 'when default' do
    it { is_expected.to have_filesystem_resource_count(0) }
    it { is_expected.to have_mount_resource_count(0) }
    it { is_expected.to compile }
  end

  context 'when ::filesystems valid' do
    filesystems =
      {
        '/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-1' => {
          ensure:  'present',
          fs_type: 'btrfs',
          options: '--uuid 3aa4ffe4-fd06-44c5-b8ab-55f79d0ea16b',
        },
      }
    let :params do
      {
        filesystems: filesystems,
      }
    end

    it { is_expected.to have_filesystem_resource_count(1) }
    it { is_expected.to contain_filesystem('/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-1').with(filesystems[:'/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-1']) }
    it { is_expected.to compile }
  end

  context 'when ::filesystems invalid' do
    invalid = [123, 'string', [1, 2, 3], true]
    invalid.each do |filesystem|
      context "when ::filesystems #{filesystem}" do
        let :params do
          {
            filesystems: filesystem,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end

  context 'when ::mounts valid' do
    mounts =
      {
        '/dev/disk/by-uuid/2020-10-21-10-31-14-00' => {
          name: '/media/cdrom',
          device: 'UUID=2020-10-21-10-31-14-00',
          ensure: 'mounted',
          fstype: 'iso9660',
          options: 'ro,x-mount.mkdir',
          atboot: true,
        },
      }
    let :params do
      {
        mounts: mounts,
      }
    end

    it { is_expected.to have_mount_resource_count(1) }
    it { is_expected.to contain_mount('/dev/disk/by-uuid/2020-10-21-10-31-14-00').with(mounts[:'/dev/disk/by-uuid/2020-10-21-10-31-14-00']) }
    it { is_expected.to compile }
  end

  context 'when ::mounts invalid' do
    invalid = [123, 'string', [1, 2, 3], true]
    invalid.each do |mount|
      context "when ::mounts #{mount}" do
        let :params do
          {
            mounts: mount,
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{expects a Hash}) }
        it { is_expected.not_to compile }
      end
    end
  end
end
