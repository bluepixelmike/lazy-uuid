require 'securerandom' # For generating new UUIDs.

# Universally unique identifier.
# Items with distinct different UUIDs should be different entities.
# Items with the same UUID should be the same entity.
# @note The naming scheme used for this class is as follows:
#   * +uuid+     - An instance of this class.
#   * +value+    - Packed string, not human readable. 16 bytes in length.
#   * +uuid_str+ - Formatted string, human readable. Formatted as xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx (8-4-4-4-12).
class Uuid
  include Comparable

  # Raw, packed byte string containing the UUID's value.
  # @return [String] Packed string, 16 bytes in length.
  attr_reader :value

  # Creates a UUID or one from an existing value.
  # @param value [String] Packed bytes with the UUID's value.
  #   The value must be a string of 16 bytes (128 bits).
  # @see generate
  def initialize(value)
    value_str = value.to_s
    fail ArgumentError, 'Packed UUID value must be 16 bytes.' unless value_str.length == 16

    # Get a copy to prevent external processes modifying the value.
    @value = value_str.dup

    # Prevent modification.
    @value.freeze
  end

  class << self

    # Generates a new (and random) UUID
    # @return [UUID] Newly generated UUID.
    def generate
      # A built-in method from Ruby to generate a valid UUID is SecureRandom.uuid.
      # However, it returns it as a formatted string.
      # The formatted string has to be converted to a packed string before it can be used.
      uuid_str = SecureRandom.uuid
      value    = pack_uuid_str(uuid_str)
      Uuid.new(value)
    end

    # Determines whether a string contains a valid formatted UUID.
    # @param uuid_str [String] String to check.
    # @return [true] The string contains a valid formatted UUID.
    # @return [false] The string does not contain a valid UUID.
    def valid_str?(uuid_str)
      if uuid_str.is_a? String
        # Check the formatting.
        # Note that the validity of the UUID isn't checked.
        !!/^\A[0-9a-f]{8}(-?)[0-9a-f]{4}\1[0-9a-f]{4}\1[0-9a-f]{4}\1[0-9a-f]{12}\z$/i.match(uuid_str)
      else
        # A string wasn't passed in.
        fail ArgumentError
      end
    end

    # Converts a UUID formatted as a string into its packed byte representation.
    # @param uuid_str [String] UUID in string form.
    # @return [String] Packed string, 16 bytes in length.
    # @!visibility private
    def pack_uuid_str(uuid_str)
      # 1) Strip hyphens.
      # 2) Collect 2 characters.
      # 3) Convert 2 characters from hex to numeric.
      # 4) Pack the numeric values into bytes in a string.
      uuid_str.delete('-').scan(/../).map(&:hex).pack('C16')
    end

    # Creates a UUID object from its string representation.
    # @param uuid_str [String] UUID in string form.
    #   The string must be in the form: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx (8-4-4-4-12)
    # @note Casing does not matter for a-f.
    # @return [Uuid] Parsed UUID from the string.
    # @return [nil] The string doesn't have a properly formatted UUID.
    # @note Dashes may be omitted from the string.
    #   This allows strings of 32 hexadecimal characters.
    def parse(uuid_str)
      if valid_str?(uuid_str)
        # Properly formatted UUID string.
        # Pack the UUID into a byte string and return a new instance.
        value = pack_uuid_str(uuid_str)
        Uuid.new(value)
      else
        # Not properly formatted.
        nil
      end
    end
  end

  # Checks for hash equality of two UUIDs.
  # @param other [Uuid] Other UUID to compare against.
  # @return [true] The UUIDs are equal.
  # @return [false] The UUIDs are different.
  # @note This method compares only {Uuid} instances.
  #   +false+ will be returned if +other+ is not a {Uuid}.
  def eql?(other)
    other.is_a?(Uuid) && eq_packed(other.value)
  end

  # Checks if two UUIDs have the same value.
  # @param other [Uuid, String] Other object to check against.
  # @return [true] The UUIDs are equal.
  # @return [false] The UUIDs are different.
  def ==(other)
    case other
      when Uuid
        # Compare two UUID instances.
        eq_packed(other.value)

      when String
        if other.length == 16
          # Compare against a packed string
          eq_packed(other)

        else
          # Compare against a formatted string
          eq_formatted(other)
        end

      else
        # Everything else can't be equated.
        false
    end
  end

  # Compares two UUIDs to each other to determine which is lower.
  # @param other [Uuid, String] Other object to compare against.
  # @return [-1] The left UUID is smaller.
  # @return [0] The UUIDs are the same.
  # @return [1] The right UUID is smaller.
  # @return [nil] The right side isn't a UUID.
  def <=>(other)
    case other
      when Uuid
        # Compare two UUID instances.
        cmp_packed(other.value)

      when String
        if other.length == 16
          # Compare against a packed string
          cmp_packed(other)

        else
          # Compare against a formatted string
          cmp_formatted(other)
        end

      else
        # Everything else can't be compared.
        nil
    end
  end

  # Produces a hash value of the UUID.
  # @return [Fixnum]
  def hash
    @value.hash
  end

  # Produces the string representation of the UUID.
  # @param dashes [Boolean] +true+ to put dashes in the output (standard format),
  #   +false+ to not put dashes.
  # @return [String] UUID in string form: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx (8-4-4-4-12)
  def to_s(dashes = true)
    bytes = @value.bytes
    if dashes
      sprintf('%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x', *bytes)
    else
      sprintf('%02x' * 16, *bytes)
    end
  end

  # Empty UUID.
  # @return [Uuid] UUID with the value 00000000-0000-0000-0000-000000000000.
  DEFAULT = Uuid.new("\x0" * 16).freeze

  private

  # Checks for equality with a packed string.
  # @param value [String] Packed string.
  # @return [true] The packed string contains an identical value.
  # @return [false] The packed string contains a different value.
  def eq_packed(value)
    # Compare the bytes in each string.
    # Byte comparison *must* be used, since == uses character comparison.
    # Bytes != characters when encoding is involved.
    @value.each_byte.with_index do |byte_a, index|
      byte_b = value.getbyte(index)
      break false if byte_a != byte_b # Abort enumeration with false value.
      break true if index == 15 # Return true on last iteration when bytes are the same.
    end
  end

  # Checks for equality with a UUID formatted as a string.
  # @param uuid_str [String] UUID formatted as a string.
  # @return [true] The formatted string contains an identical value.
  # @return [false] The formatted string contains a different value.
  def eq_formatted(uuid_str)
    klass = self.class
    if klass.valid_str?(uuid_str)
      # Format is valid.
      # Compare it to packed string.
      value = klass.pack_uuid_str(uuid_str)
      eq_packed(value)
    else
      # Invalid format can't be equal.
      false
    end
  end

  # Compares the ordering with a packed string.
  # @param value [String] Packed string.
  # @return [-1] The left UUID is smaller.
  # @return [0] The UUIDs are the same.
  # @return [1] The right UUID is smaller.
  # @return [nil] The right side isn't a UUID.
  def cmp_packed(value)
    # Compare the bytes in each string.
    # Byte comparison *must* be used, since <=> uses character comparison.
    # Bytes != characters when encoding is involved.
    @value.bytes.each_with_index do |byte_a, index|
      byte_b = value.getbyte(index)
      result = byte_a <=> byte_b
      break result if result != 0 # Abort enumeration with result.
      break 0 if index == 15 # Return 0 on last byte if they're the same.
    end
  end

  # Checks for equality with a UUID formatted as a string.
  # @param uuid_str [String] UUID formatted as a string.
  # @return [-1] The left UUID is smaller.
  # @return [0] The UUIDs are the same.
  # @return [1] The right UUID is smaller.
  # @return [nil] The right side isn't a UUID.
  def cmp_formatted(uuid_str)
    klass = self.class
    if klass.valid_str?(uuid_str)
      # Format is valid.
      # Compare it to packed string.
      value = klass.pack_uuid_str(uuid_str)
      cmp_packed(value)
    else
      # Invalid format can't be equal.
      nil
    end
  end

end
