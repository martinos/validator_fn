require "date"
RSpec.describe ValidatorFn do
  include ValidatorFn

  it "has a version number" do
    expect(ValidatorFn::VERSION).not_to be nil
  end

  describe "validation" do
    it "validates non nil" do
      expect(something.(1)).to eq 1
      expect { something.(nil) }.to raise_error(ValidatorFn::Error)
    end

    it "validates that it can be anything even nil" do
      expect(any.(1)).to eq 1
      expect(any.(nil)).to eq nil
    end

    it "validates it is of a certain class" do
      expect(is_a.(String).("air")).to eq "air"
      expect { is_a.(String).(23) }.to raise_error(ValidatorFn::Error)
    end

    it "validates that it is a bool" do
      expect(is_a_bool.(true)).to eq true
      expect(is_a_bool.(false)).to eq false
      expect { is_a_bool.("sdf") }.to raise_error(ValidatorFn::Error)
    end

    it "validates maybe" do
      expect(maybe.(is_a.(String)).("")).to eq ""
      expect(maybe.(is_a.(String)).(nil)).to eq nil
      expect { maybe.(is_a.(String)).(12) }.to raise_error(ValidatorFn::Error)
    end

    context "hash_of" do
      it "test for valid field" do
        expect(hash_of.(age: (is_a.(Integer))).(age: 12)).to eq({ age: 12 })
      end

      it "raises an exception for invalid field" do
        expect { hash_of.(age: (is_a.(Integer))).(age: "asdf") }.to raise_error(ValidatorFn::Error)
      end

      it "can apply a conversion" do
        # We should be able to apply a transformation on the value
        expect(hash_of.(age: (is_a.(Integer) >> ->a { a + 2 })).(age: 12)).to eq({ age: 14 })
      end

      it "raises an error if field is not present" do
        expect { hash_of.(unexisting_key: (is_a.(Integer))).(age: "asdf") }.to raise_error(ValidatorFn::Error)
      end

      it "doesn't raise an error if a key is absent and the value is tested for nility" do
        # we are not discrimining between a missing key and a field with nil value
        # Because the fn passed passed to the hash defn is only applied to the value
        # Thus we cannot have a way to discriminate between absent field and nil field
        expect(hash_of.(unexisting_key: is_nil).(age: 12)).to eq({ unexisting_key: nil })
      end

      it "tests if a field is missing" do
        expect { hash_of.(id: is_a.(String)).({}) }.to raise_error(ValidatorFn::Error)
      end

      it "filters out field that where not defined" do
        expect(hash_of.(age: is_a.(Integer)).(age: 12, name: "Joe")).to eq({ age: 12 })
      end
    end

    it "validates an array" do
      expect(array_of.(is_a.(String)).([])).to eq []
      expect(array_of.(is_a.(Integer)).([12, 34])).to eq [12, 34]
      expect { array_of.(is_a.(String)).([12]) }.to raise_error(ValidatorFn::Error)
    end

    it "validates matches" do
      expect { matches.(/\d{10}/).("5143334444") }.to_not raise_error
      expect { matches.(/\d{10}/).("asdf") }.to raise_error(ValidatorFn::Error)
    end

    it "validates a value that can be either one thing or another" do
      expect(either.(is_a.(String)).(is_a.(Integer)).("tata")).to eq "tata"
      expect(either.(is_a.(String)).(is_a.(Integer)).(12)).to eq 12
      expect { either.(is_a.(String)).(is_a.(Integer)).(/asdf/) }.to raise_error(ValidatorFn::Error)
    end

    it "validates complex structure" do
      address = hash_of.({ street_number: is_a.(String),
                           city: is_a.(String) })
      user = hash_of.({ name: is_a.(String),
                        age: apply.(->a { Integer(a) }) >> is_a.(Integer),
                        birth_date: maybe.(is_a.(Date)),
                        addresses: array_of.(address) })
      me = { name: "John",
            age: 12,
            birth_date: Date.new(1990, 2, 1),
            addresses: [{ street_number: "234",
                          city: "Montreal",
                          country: "asf" }] }

      user.(me)
    end

    it "generates code for complex structures" do
      user = { user: { name: "Joe Bloe", age: 44,
                     friends: [{ name: "john doe", age: 34 },
                               { name: "Janis", age: 27 }] } }

      validate_code = generate_validator.(user)
      expected_code = <<EOF
hash_of.({ :user => hash_of.({ :name => is_a.(String),
  :age => is_a.(Integer),
  :friends => array_of.( hash_of.({ :name => is_a.(String),
  :age => is_a.(Integer) }) ) }) })
EOF
      expect(validate_code).to eq(expected_code.chomp)
      validate = eval(validate_code)
    end
  end
end
