PuppetLint.new_check(:legacy_fact) do
  LEGACY_FACTS_STATIC = {
    'architecture' => "facts['os']['architecture']",
    'augeasversion' => "",
    'blockdevices' => "",
    'bios_release_date' => "",
    'bios_vendor' => "",
    'bios_version' => "",
    'boardassettag' => "",
    'boardmanufacturer' => "",
    'boardproductname' => "",
    'boardserialnumber' => "",
    'chassisassettag' => "",
    'chassistype' => "",
    'dhcp_servers' => "",
    'domain' => "facts['networking']['domain']",
    'fqdn' => "facts['networking']['fqdn']",
    'gid' => "",
    'hardwareisa' => "facts['os']['hardware']",
    'hardwaremodel' => "",
    'hostname' => "",
    'id' => "",
    'interfaces' => "",
    'ipaddress' => "",
    'ipaddress6' => "",
    'lsbdistcodename' => "",
    'lsbdistdescription' => "",
    'lsbdistid' => "",
    'lsbdistrelease' => "",
    'lsbmajdistrelease' => "",
    'lsbminordistrelease' => "",
    'lsbrelease' => "",
    'macaddress' => "",
    'macosx_buildversion' => "",
    'macosx_productname' => "",
    'macosx_productversion' => "",
    'macosx_productversion_major' => "",
    'macosx_productversion_minor' => "",
    'manufacturer' => "",
    'memoryfree' => "",
    'memoryfree_mb' => "",
    'memorysize' => "",
    'memorysize_mb' => "",
    'netmask' => "",
    'netmask6' => "",
    'network' => "",
    'network6' => "",
    'operatingsystem' => "facts['os']['release']",
    'operatingsystemmajrelease' => "facts['os']['release']['major']",
    'operatingsystemrelease' => "facts['os']['release']['full']",
    'osfamily' => "facts['os']['family']",
    'physicalprocessorcount' => "",
    'processorcount' => "",
    'productname' => "",
    'rubyplatform' => "",
    'rubysitedir' => "",
    'rubyversion' => "",
    'selinux' => "",
    'selinux_config_mode' => "",
    'selinux_config_policy' => "",
    'selinux_current_mode' => "",
    'selinux_enforced' => "",
    'selinux_policyversion' => "",
    'serialnumber' => "",
    'swapencrypted' => "",
    'swapfree' => "",
    'swapfree_mb' => "",
    'swapsize' => "",
    'swapsize_mb' => "",
    'system32' => "",
    'uptime' => "",
    'uptime_days' => "",
    'uptime_hours' => "",
    'uptime_seconds' => "",
    'uuid' => "",
    'xendomains' => "",
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
