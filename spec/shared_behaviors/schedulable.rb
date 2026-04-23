RSpec.shared_examples 'schedulable' do |factory:, next_date_column:|
  describe 'Schedulable' do
    it 'defines enum for frequency' do
      is_expected.to define_enum_for(:frequency).with_values(daily: 0, weekly: 1, monthly: 2, yearly: 3)
    end

    describe '.validations' do
      subject { create(factory) }

      it { is_expected.to validate_presence_of(:amount) }
      it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0.01) }
      it { is_expected.to validate_presence_of(:frequency_amount) }
      it do
        is_expected.to validate_numericality_of(:frequency_amount)
          .is_greater_than_or_equal_to(1)
          .only_integer
      end

      it { is_expected.to validate_presence_of(next_date_column) }

      it "when #{next_date_column} is in the future" do
        record = build_stubbed(factory, next_date_column => 1.day.from_now.to_date)
        expect(record).to be_valid
      end

      it "when #{next_date_column} is today" do
        record = build_stubbed(factory, next_date_column => Date.today)
        expect(record).to be_valid
      end

      it "when #{next_date_column} is in the past" do
        record = build_stubbed(factory, next_date_column => 1.day.ago.to_date)
        expect(record).to be_invalid
      end

      it 'when ends_on is more than a year in the past' do
        record = build_stubbed(factory, ends_on: 1.year.ago.to_date - 1.day)
        expect(record).to be_invalid
        expect(record.errors[:ends_on]).to be_present
      end

      it 'when ends_on is less than a year in the past' do
        record = build_stubbed(factory, ends_on: 1.year.ago.to_date + 1.day)
        expect(record).to be_valid
      end
    end

    describe '.active' do
      it 'returns only active records' do
        active_record = create(factory, ends_on: 1.day.from_now.to_date)
        never_ends_record = create(factory, ends_on: nil)
        create(factory, ends_on: 1.day.ago.to_date) # ended

        expect(described_class.active).to contain_exactly(active_record, never_ends_record)
      end
    end

    describe '.ended' do
      it 'returns only ended records' do
        create(factory, ends_on: 1.day.from_now.to_date) # active
        create(factory, ends_on: nil) # never ends
        ended_record = create(factory, ends_on: 1.day.ago.to_date)

        expect(described_class.ended).to contain_exactly(ended_record)
      end
    end

    describe '#advance_schedule' do
      let(:initial_date) { Date.current }

      it 'advances by the correct number of days' do
        record = create(factory, frequency_amount: 5, frequency: :daily, next_date_column => initial_date)
        record.advance_schedule
        expect(record.send(next_date_column)).to eq(5.days.since(initial_date))
      end

      it 'advances by the correct number of weeks' do
        record = create(factory, frequency_amount: 2, frequency: :weekly, next_date_column => initial_date)
        record.advance_schedule
        expect(record.send(next_date_column)).to eq(2.weeks.since(initial_date))
      end

      it 'advances by the correct number of months' do
        record = create(factory, frequency_amount: 1, frequency: :monthly, next_date_column => initial_date)
        record.advance_schedule
        expect(record.send(next_date_column)).to eq(1.month.since(initial_date))
      end

      it 'advances by the correct number of years' do
        record = create(factory, frequency_amount: 1, frequency: :yearly, next_date_column => initial_date)
        record.advance_schedule
        expect(record.send(next_date_column)).to eq(1.year.since(initial_date))
      end
    end
  end
end
