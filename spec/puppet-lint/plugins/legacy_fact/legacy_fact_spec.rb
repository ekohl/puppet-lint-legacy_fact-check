require 'spec_helper'

describe 'legacy_fact' do
  let(:msg) { 'legacy fact used' }

  context 'with fix disabled' do
    tests = [
      ['top scoped', '$operatingsystem'],
      ['absolute scoped', '$::operatingsystem'],
      ['fact variable with single quotes', "$facts['operatingsystem']"],
      ['fact variable with double quotes', '$facts["operatingsystem"]'],
      ['regex-based variable', '$ipaddress_eth0'],
      #['fact function with single quotes', "fact('operatingsystem')"],
      #['fact function with double quotes', 'fact("operatingsystem")'],
    ]
    tests.each do |ctx, sample|
      context "using #{ctx}: #{sample}" do
        let(:code) { sample }

        it 'should detect a single problem' do
          expect(problems).to have(1).problem
        end

        it 'should create a warning' do
          expect(problems).to contain_warning(msg).on_line(1).in_column(1)
        end
      end
    end

    context 'code using modern fact' do
      let(:code) { "$facts['os']['name']" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    tests = [
      ['top scoped', '$operatingsystem', "$facts['os']['release']"],
      ['absolute scoped', '$::operatingsystem', "$facts['os']['release']"],
      ['fact variable with single quotes', "$facts['operatingsystem']", "$facts['os']['release']"],
      ['fact variable with double quotes', '$facts["operatingsystem"]', "$facts['os']['release']"],
      ['regex-based variable', '$ipaddress_eth0', "$facts['networking']['eth0']['ip']"],
    ]
    tests.each do |ctx, sample, replacement|
      context "using #{ctx}: #{sample}" do
        let(:code) { sample }

        it 'should detect a single problem' do
          expect(problems).to have(1).problem
        end

        it 'should fix the problem' do
          expect(problems).to contain_fixed(msg).on_line(1).in_column(1)
        end

        it 'should add a newline to the end of the manifest' do
          expect(manifest).to eq(replacement)
        end
      end
    end

    context 'code using legacy fact without replacement' do
      let(:code) { "$macosx_buildversion" }

      it 'should detect a single problem' do
        expect(problems).to have(1).problem
      end

        it 'should not fix the problem' do
          expect(problems).to contain_warning(msg).on_line(1).in_column(1)
        end

      it 'should not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'code using modern fact' do
      let(:code) { "$facts['os']['name']" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end

      it 'should not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end
  end
end
