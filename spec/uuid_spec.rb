require_relative 'spec_helper'

RSpec::Matchers.define :be_a_valid_uuid_string do
  match do |actual|
    !!/^\A[0-9a-f]{8}(-?)[0-9a-f]{4}\1[1-5][0-9a-f]{3}\1[89ab][0-9a-f]{3}\1[0-9a-f]{12}\z$/i.match(actual)
  end

  description do
    'be a valid UUID string'
  end

  failure_message do |actual|
    "expected that #{actual} would be a valid UUID string"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not be a valid UUID string"
  end
end

RSpec.describe Uuid do

  describe '::DEFAULT' do
    subject { Uuid::DEFAULT }

    it 'is all zeroes' do
      is_expected.to eq("\x0" * 16)
    end

    it 'is frozen' do
      is_expected.to be_frozen
    end
  end
  
  describe '#initialize' do
    context 'with a valid value' do
      let(:uuid_value) { build(:uuid_value) }
      subject(:uuid) { described_class.new(uuid_value) }

      describe 'the value' do
        subject { uuid.value }

        it 'is stored' do
          is_expected.to eq uuid_value
        end
      end
    end

    context 'with an invalid value' do
      let(:uuid_value) { 'foobar' }

      it 'throws an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.generate' do
    subject(:uuid) { described_class.generate }

    describe 'the value' do
      subject { uuid.value }

      # The UUID standards don't allow generated UUID to be all zeroes.
      it 'is not DEFAULT' do
        is_expected.to_not eq("\x0" * 16)
      end

      # The chances of two randomly generated UUIDs being identical is virtually impossible.
      it 'is random' do
        other = build(:uuid)
        is_expected.to_not eq other
      end
    end

    describe 'the string' do
      subject { uuid.to_s }

      it 'is valid' do
        is_expected.to be_a_valid_uuid_string
      end
    end
  end

  describe '.parse' do
    subject { described_class.parse(uuid_str) }

    context 'with a valid argument' do
      context 'with dashes' do
        let(:uuid_str) { build(:uuid_str) }

        it 'parses correctly' do
          is_expected.to eq uuid_str
        end
      end

      context 'without dashes' do
        let(:uuid_str) { build(:uuid_str, :no_dashes) }

        it 'parses correctly' do
          is_expected.to eq uuid_str
        end
      end
    end

    context 'with a malformed string' do
      let(:uuid_str) { 'foobar' }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'with an invalid argument' do
      let(:uuid_str) { 5 }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'with newlines' do
      let(:uuid_str) { "\n" + build(:uuid_str) + "\n" }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end

  describe '#value' do
    let(:uuid) { build(:uuid) }
    subject(:value) { uuid.value }

    it 'is a string' do
      is_expected.to be_a String
    end

    it 'is frozen' do
      is_expected.to be_frozen
    end

    it 'is 16 bytes' do
      expect(value.length).to be 16
    end
  end

  describe '#eql?' do
    let(:uuid) { build(:uuid) }
    subject { uuid.eql?(other) }

    context 'with two identical UUIDs' do
      let(:other) { build(:uuid, :source => uuid) }

      it 'returns true' do
        is_expected.to eq true
      end
    end

    context 'with two different UUIDs' do
      let(:other) { build(:uuid) }

      it 'returns false' do
        is_expected.to eq false
      end
    end

    context 'without a UUID' do
      let(:other) { 'foobar' }

      it 'returns false' do
        is_expected.to eq false
      end
    end
  end

  describe '#==' do
    let(:uuid) { build(:uuid) }
    subject { uuid == other }

    context 'with equal UUIDs' do
      let(:other) { build(:uuid, :source => uuid) }
      
      it 'is true' do
        is_expected.to be true
      end
    end

    context 'with the same instance' do
      let(:other) { uuid }
      
      it 'is true' do
        is_expected.to be true
      end
    end

    context 'with unequal UUIDs' do
      let(:other) { build(:uuid) }
      
      it 'is false' do
        is_expected.to be false
      end
    end

    context 'with nil' do
      let(:other) { nil }
      
      it 'is false' do
        is_expected.to be false
      end
    end

    context 'with a malformed string' do
      let(:other) { 'foobar' }
      
      it 'is false' do
        is_expected.to be false
      end
    end

    context 'with a non-string' do
      let(:other) { 5 }
      
      it 'is false' do
        is_expected.to be false
      end
    end

    context 'with identical value' do
      let(:other) { uuid.value }
      
      it 'is true' do
        is_expected.to be true
      end
    end

    context 'with identical string' do
      let(:other) { uuid.to_s }
      
      it 'is true' do
        is_expected.to be true
      end
    end
  end

  describe '#<=>' do
    let(:lesser) { 'de305d54-75b4-431b-adb2-eb6b9e546014' }
    let(:greater) { 'de305d54-75b4-431b-adb2-eb6b9e546020' }
    subject { first <=> second }

    context 'with an equal UUID' do
      let(:first)  { build(:uuid) }
      let(:second) { build(:uuid, :source => first) }

      it 'is 0' do
        is_expected.to eq 0
      end
    end

    context 'with the same instance' do
      let(:first)  { build(:uuid) }
      let(:second) { first }

      it 'is 0' do
        is_expected.to eq 0
      end
    end

    context 'with a lesser UUID' do
      let(:first)  { build(:uuid, :source => greater) }
      let(:second) { build(:uuid, :source => lesser) }

      it 'is 1' do
        is_expected.to eq 1
      end
    end

    context 'with a greater UUID' do
      let(:first)  { build(:uuid, :source => lesser) }
      let(:second) { build(:uuid, :source => greater) }

      it 'is -1' do
        is_expected.to eq(-1)
      end
    end

    context 'with nil' do
      let(:first)  { build(:uuid) }
      let(:second) { nil }

      it 'is nil' do
        is_expected.to be_nil
      end
    end

    context 'with a number' do
      let(:first)  { build(:uuid) }
      let(:second) { 500 }

      it 'is nil' do
        is_expected.to be_nil
      end
    end

    context 'with an identical value' do
      let(:first)  { build(:uuid) }
      let(:second) { first.value }

      it 'is 0' do
        is_expected.to eq 0
      end
    end

    context 'with a lesser value' do
      let(:first)  { build(:uuid, :source => greater) }
      let(:second) { build(:uuid_value, :source => lesser) }

      it 'is 1' do
        is_expected.to eq 1
      end
    end

    context 'with a greater value' do
      let(:first)  { build(:uuid, :source => lesser) }
      let(:second) { build(:uuid_value, :source => greater) }

      it 'is -1' do
        is_expected.to eq(-1)
      end
    end

    context 'with an equal string' do
      let(:first)  { build(:uuid) }
      let(:second) { first.to_s }

      it 'is 0' do
        is_expected.to eq 0
      end
    end

    context 'with a lesser string' do
      let(:first)  { build(:uuid, :source => greater) }
      let(:second) { lesser }

      it 'is 1' do
        is_expected.to eq 1
      end
    end

    context 'with a greater string' do
      let(:first)  { build(:uuid, :source => lesser) }
      let(:second) { greater }

      it 'is -1' do
        is_expected.to eq(-1)
      end
    end

    context 'with an invalid string' do
      let(:first)  { build(:uuid) }
      let(:second) { 'foobar' }

      it 'is nil' do
        is_expected.to be_nil
      end
    end
  end

  describe '#hash' do
    let(:uuid) { build(:uuid) }
    subject { uuid.hash }

    it 'is a Fixnum' do
      is_expected.to be_a Fixnum
    end

    context 'with identical UUIDs' do
      let(:first)  { build(:uuid) }
      let(:second) { build(:uuid, :source => first) }

      it 'returns identical values' do
        expect(first.hash).to eq(second.hash)
      end
    end

    context 'with different UUIDs' do
      let(:first)  { build(:uuid) }
      let(:second) { build(:uuid) }

      it 'returns different values' do
        expect(first.hash).to_not eq(second.hash)
      end
    end
  end

  describe '#to_s' do
    let(:uuid_str) { build(:uuid_str) }
    let(:uuid) { build(:uuid, :source => uuid_str) }
    subject { uuid.to_s }

    it 'is a String' do
      is_expected.to be_a String
    end

    it 'is a valid UUID string' do
      is_expected.to be_a_valid_uuid_string
    end

    it 'equals the initial value' do
      is_expected.to eq uuid_str
    end

    it 'contains dashes' do
      is_expected.to include '-'
    end

    context 'with bytes less than 16' do
      let(:uuid_str) { '05305d54-7502-431b-adb2-eb6b9e546000' }
      let(:uuid) { build(:uuid, :source => uuid_str) }

      it 'pads with zeroes' do
        is_expected.to eq uuid_str
      end
    end

    context 'with dashes set to false' do
      let(:uuid_str) { build(:uuid_str, :no_dashes) }
      subject { uuid.to_s(false) }

      it 'is a String' do
        is_expected.to be_a String
      end

      it 'is a valid UUID string' do
        is_expected.to be_a_valid_uuid_string
      end

      it 'equals the initial value' do
        is_expected.to eq uuid_str
      end

      it 'does not contain dashes' do
        is_expected.not_to include '-'
      end

      context 'with bytes less than 16' do
        let(:uuid_str) { '05305d547502431badb2eb6b9e546000' }
        let(:uuid) { build(:uuid, :source => uuid_str) }

        it 'pads with zeroes' do
          is_expected.to eq uuid_str
        end
      end
    end
  end

end
