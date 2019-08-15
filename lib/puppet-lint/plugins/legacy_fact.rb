PuppetLint.new_check(:legacy_fact) do
  LEGACY_FACTS_STATIC = {
    'operatingsystem' => "facts['os']['release']",
  }

  LEGACY_FACTS_REGEX = {
    /^ipaddress_(.+)$/ => "facts['networking']['%s']['ip']"
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
    problem[:token].value = replacement_fact(normalize_fact(problem[:token].value))
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
    find_static_fact(fact) || find_regex_fact(fact) || fact
  end
end
