require 'securerandom'
require 'lazy-uuid/uuid'

FactoryGirl.define do
  factory :uuid_str, class: String do
    trait :no_dashes do
      after(:build) do |uuid_str|
        uuid_str.delete!('-')
      end
    end

    initialize_with { SecureRandom.uuid }
  end

  factory :uuid_value, class: String do
    transient do
      association :source, :factory => :uuid_str, :strategy => :build
    end

    initialize_with { source.delete('-').scan(/../).map(&:hex).pack('C*') }
  end

  factory :uuid, class: Uuid do
    transient do
      source nil
    end

    initialize_with do
      case source
        when nil
          Uuid.generate
        when Uuid
          Uuid.new(source.value)
        else
          if source.length == 16
            Uuid.new(source)
          else
            Uuid.new(build(:uuid_value, :source => source))
          end
      end
    end
  end
end
