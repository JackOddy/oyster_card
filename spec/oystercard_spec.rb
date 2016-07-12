require 'oystercard'

describe Oystercard do
  let(:subject) { Oystercard.new }
  let(:station) { double(:station) }


  describe '#balance' do
    it { is_expected.to respond_to(:balance) }
    it 'returns balance of oystercard' do
      expect(subject.balance).to eq 0
    end
  end

  describe'#top_up' do
    it { is_expected.to respond_to(:top_up).with(1).argument }
    it 'tops up card balance' do
      expect{ subject.top_up(10) }.to  change{ subject.balance }.by 10
    end
    it 'cannot exceed the credit limit' do
      max_out = described_class::MAX_BALANCE
      subject.top_up max_out
      expect{subject.top_up(0.01)}.to raise_error "Balance cannot exceed #{max_out}."
    end
  end

  describe '#touch_in(station)' do
    before do
      subject.top_up(1)
    end
    it "records a journey as in progress" do
      expect(subject.touch_in(station)).to eq station
    end
    it 'raises error if balance is below a minimum amount' do
      subject = described_class.new
      expect{subject.touch_in(station)}.to(raise_error("Balance is below £#{described_class::MIN_BALANCE}"))
    end
    it 'records entry station' do
      subject.touch_in(station)
      expect(subject.entry_station).to(eq(station))
    end
  end

  describe '#touch_out' do
    before do
      subject.top_up(10)
      subject.touch_in(station)
    end
    it "ends an in progress journey" do
      expect(subject.touch_out).to(eq(nil))
    end
    it "deducts the fare from the balance" do
      fare = -(described_class::FARE)
      expect{subject.touch_out}.to(change{subject.balance}.by(fare))
    end
  end

  describe '#in_journey' do
    before do
      subject.top_up(10)
      subject.touch_in(station)
    end
    it "is true when a card has been touched in" do
      expect(subject).to(be_in_journey)
    end
    it "is false when a card has been touched out" do
      subject.touch_out
      expect(subject).not_to(be_in_journey)
    end
  end

end
