PuppetLint.new_check(:legacy_fact) do
  LEGACY_FACTS_STATIC = {
    'architecture' => "facts['os']['architecture']",
    'augeasversion' => "facts['augeas']['version']",
    'blockdevices' => "", # TODO facts['disks'].keys() + join()
    'bios_release_date' => "facts['dmi']['bios']['release_date']",
    'bios_vendor' => "facts['dmi']['bios']['vendor']",
    'bios_version' => "facts['dmi']['bios']['version']",
    'boardassettag' => "facts['dmi']['board']['asset_tag']",
    'boardmanufacturer' => "facts['dmi']['board']['manufacturer']",
    'boardproductname' => "facts['dmi']['board']['product']",
    'boardserialnumber' => "facts['dmi']['board']['serial_number']",
    'chassisassettag' => "",
    'chassistype' => "facts['dmi']['chassis']['type']",
    'dhcp_servers' => "",
    'domain' => "facts['networking']['domain']",
    'fqdn' => "facts['networking']['fqdn']",
    'gid' => "facts['identity']['gid']",
    'hardwareisa' => "facts['os']['hardware']",
    'hardwaremodel' => "",
    'hostname' => "facts['networking']['hostname']",
    'id' => "facts['identity']['uid']",
    'interfaces' => "", # TODO facts['networking']['interfaces'].keys() + join()
    'ipaddress' => "facts['networking']['ip']",
    'ipaddress6' => "facts['networking']['ip6']",
    'lsbdistcodename' => "",
    'lsbdistdescription' => "",
    'lsbdistid' => "",
    'lsbdistrelease' => "",
    'lsbmajdistrelease' => "",
    'lsbminordistrelease' => "",
    'lsbrelease' => "",
    'macaddress' => "facts['networking']['mac']",
    'macosx_buildversion' => "",
    'macosx_productname' => "",
    'macosx_productversion' => "",
    'macosx_productversion_major' => "",
    'macosx_productversion_minor' => "",
    'manufacturer' => "facts['dmi']['manufacturer']",
    'memoryfree' => "facts['memory']['system']['available']",
    'memoryfree_mb' => "facts['memory']['system']['available_bytes'] / 1024 / 1024",
    'memorysize' => "facts['memory']['system']['total']",
    'memorysize_mb' => "facts['memory']['system']['total_bytes'] / 1024 / 1024",
    'netmask' => "facts['networking']['netmask']",
    'netmask6' => "facts['networking']['netmask6']",
    'network' => "facts['networking']['network']",
    'network6' => "facts['networking']['network6']",
    'operatingsystem' => "facts['os']['release']",
    'operatingsystemmajrelease' => "facts['os']['release']['major']",
    'operatingsystemrelease' => "facts['os']['release']['full']",
    'osfamily' => "facts['os']['family']",
    'physicalprocessorcount' => "facts['processors']['physicalcount']",
    'processorcount' => "facts['processors']['count']",
    'productname' => "facts['dmi']['product']['name']",
    'rubyplatform' => "facts['ruby']['platform']",
    'rubysitedir' => "facts['ruby']['sitedir']",
    'rubyversion' => "facts['ruby']['version']",
    'selinux' => "facts['os']['selinux']['enabled']",
    'selinux_config_mode' => "facts['os']['selinux']['config_mode']",
    'selinux_config_policy' => "facts['os']['selinux']['config_policy']",
    'selinux_current_mode' => "facts['os']['selinux']['current_mode']",
    'selinux_enforced' => "facts['os']['selinux']['enforced']",
    'selinux_policyversion' => "facts['os']['selinux']['policy_version']",
    'serialnumber' => "facts['dmi']['product']['serial_number']",
    'swapencrypted' => "facts['memory']['swap']['encrypted']",
    'swapfree' => "facts['memory']['swap']['available']",
    'swapfree_mb' => "facts['memory']['swap']['available_bytes'] / 1024 / 1024",
    'swapsize' => "facts['memory']['swap']['total']",
    'swapsize_mb' => "facts['memory']['swap']['total_bytes'] / 1024 / 1024",
    'system32' => "",
    'uptime' => "facts['system_update']['uptime']",
    'uptime_days' => "facts['system_update']['days']",
    'uptime_hours' => "facts['system_update']['hours']",
    'uptime_seconds' => "facts['system_update']['seconds']",
    'uuid' => "facts['dmi']['product']['uuid']",
    'xendomains' => "", # TODO facts['xen']['domains'] + join()
    'zonename' => "",
    'zones' => "",
  }

  LEGACY_FACTS_REGEX = {
    /^blockdevice_(.+)_model$/ => "facts['disks']['%s']['model']",
    /^blockdevice_(.+)_size$/ => "facts['disks']['%s']['size']",
    /^blockdevice_(.+)_vendor$/ => "facts['disks']['%s']['vendor']",
    /^ipaddress6_(.+)$/ => "facts['networking']['%s']['ip6']",
    /^ipaddress_(.+)$/ => "facts['networking']['%s']['ip']",
    /^ldom_(.+)$/ => "",
    /^macaddress_(.+)$/ => "facts['networking']['%s']['mac']",
    /^mtu_(.+)$/ => "facts['networking']['%s']['mtu']",
    /^netmask6_(.+)$/ => "facts['networking']['%s']['netmask6']",
    /^netmask_(.+)$/ => "facts['networking']['%s']['netmask']",
    /^network6_(.+)$/ => "facts['networking']['%s']['network6']",
    /^network_(.+)$/ => "facts['networking']['%s']['network']",
    /^processor(.+)$/ => "facts['processors']['model'][%s]",
    /^sp_(.+)$/ => "",
    /^ssh(.+)key$/ => "facts['ssh']['%s']['key']",
    /^sshfp_(.+)$/ => "", # TODO original is "facts['ssh']['%s']['sha256']" and sha1
    /^zone_(.+)_brand$/ => "",
    /^zone_(.+)_id$/ => "",
    /^zone_(.+)_iptype$/ => "",
    /^zone_(.+)_name$/ => "",
    /^zone_(.+)_path$/ => "",
    /^zone_(.+)_status$/ => "",
    /^zone_(.+)_uuid$/ => "",
  }

  def check
    tokens.select { |r|
      Set[:VARIABLE, :UNENC_VARIABLE].include? r.type
    }.each do |token|
      if is_legacy_fact(normalize_fact(token.value))
        notify :warning, {
          :message => 'legacy fact used',
          :line    => token.line,
          :column  => token.column,
          :token   => token,
        }
      end
    end
  end

  def fix(problem)
    replacement = replacement_fact(normalize_fact(problem[:token].value))
    raise PuppetLint::NoFix if replacement.nil? || replacement.empty?
    problem[:token].value = replacement
  end

  private

  def normalize_fact(fact)
    fact.gsub(/^(::)?(.+)$/, '\2').gsub(/^facts\[("|')(.+)\1\]/, '\2')
  end

  def find_static_fact(fact)
    LEGACY_FACTS_STATIC[fact]
  end

  def find_regex_fact(fact)
    LEGACY_FACTS_REGEX.each do |pattern, replacement|
      if (md = pattern.match(fact))
        return replacement % md.captures
      end
    end

    nil
  end

  def is_legacy_fact(fact)
    !find_static_fact(fact).nil? || !find_regex_fact(fact).nil?
  end

  def replacement_fact(fact)
    find_static_fact(fact) || find_regex_fact(fact)
  end
end
