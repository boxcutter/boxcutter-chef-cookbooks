default['fb_init'] = {
  'firstboot_os' => File.exist?('/root/firstboot_os'),
  'firstboot_tier' => File.exist?('/root/firstboot_tier'),
}