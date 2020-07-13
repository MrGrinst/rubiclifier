module Rubiclifier
  describe Args do
    def subject(*args)
      described_class.new(args)
    end

    context "#command" do
      it "returns the first arg if one exists" do
        expect(subject("first").command).to eq("first")
      end

      it "returns nil if no first arg exists" do
        expect(subject.command).to be_nil
      end
    end

    context "#first_option" do
      it "returns the second arg if one exists" do
        expect(subject("first", "second").first_option).to eq("second")
      end

      it "returns nil if no second arg exists" do
        expect(subject("first").first_option).to be_nil
      end
    end

    context "#none?" do
      it "returns true if no args exist" do
        expect(subject.none?).to eq(true)
      end

      it "returns false if an arg exists" do
        expect(subject("test").none?).to eq(false)
      end
    end

    context "#string" do
      it "returns arg by full name" do
        expect(subject("first", "--string", "stuff").string("string")).to eq("stuff")
      end

      it "returns arg by alias" do
        expect(subject("first", "-s", "stuff").string("string", "s")).to eq("stuff")
      end

      it "returns nil if neither exist" do
        expect(subject("first", "-s", "stuff").string("none", "n")).to be_nil
      end
    end

    context "#number" do
      it "returns arg by full name" do
        expect(subject("first", "--number", "10").number("number")).to eq(10)
      end

      it "returns arg by alias" do
        expect(subject("first", "-n", "10").number("number", "n")).to eq(10)
      end

      it "returns nil if neither exist" do
        expect(subject("first", "-s", "stuff").number("number", "n")).to be_nil
      end
    end

    context "#boolean" do
      it "returns true if full name is passed" do
        expect(subject("first", "--flag", "--another", "stuff").boolean("flag")).to eq(true)
      end

      it "returns true if alias is passed" do
        expect(subject("first", "-f", "--another", "stuff").boolean("flag", "f")).to eq(true)
      end

      it "returns false if neither is passed" do
        expect(subject("first", "-s", "stuff").boolean("flag", "f")).to eq(false)
      end
    end
  end
end
