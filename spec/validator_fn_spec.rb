require "validator_fn"

RSpec.describe ValidatorFn do
  include ValidatorFn
  it "has a version number" do
    expect(ValidatorFn::VERSION).not_to be nil
  end

  describe "validation" do
    it "validates integer" do
      expect { int.("Tata") }.to raise_error(ValidatorFn::Error)
      expect { int.(12) }.not_to raise_error
    end

    it "validates non nil" do
      expect { something.(nil) }.to raise_error(ValidatorFn::Error)
      expect { something.(1) }.to_not raise_error
    end

    it "validates a has" do
      expect { hash_of.(age: (int)).(age: "asdf") }.to raise_error(ValidatorFn::Error)
      expect { hash_of.(age: (int)).(age: 12) }.to_not raise_error
    end

    it "validates an array" do
      expect { array_of.(is_a.(String)).([]) }.to_not raise_error
      expect { array_of.(is_a.(String)).([12]) }.to raise_error(ValidatorFn::Error)
    end

    it "validates a complex stucture" do
      attachment = { "order_type" => "sent to carrier",
                     "customer" => "swiftvox",
                     "company_name" => nil,
                     "first_name" => "eduardo prenda",
                     "last_name" => nil,
                     "dids" => "5147257161",
                     "to_phone_num" => nil,
                     "street_number" => "8842",
                     "street_name" => "paul corbeil  ",
                     "floor" => "", "suite" => "",
                     "city" => "st-leonard",
                     "postal_code" => "h1r 3a2",
                     "province" => "qc",
                     "local_provider" => nil,
                     "reseller" => "",
                     "created" => "2020-12-22",
                     "duedate" => "2021-01-07",
                     "account" => "",
                     "comments" => nil,
                     "pri" => ["swiftvox_1001"],
                     "sales_comments" => nil, "status" => nil, "ispt_draft_id" => 1,
                     "ispt_pon_id" => "137340", "ispt_customer_email" => "lnp@voip.ms", "reference" => "" }

      validate_code = generate_validator.(attachment)
      validate = eval(validate_code)
      attachment["pri"] = [12]
      handle_error.(error_str.(0)).(validate).(attachment)
    end
  end
end
