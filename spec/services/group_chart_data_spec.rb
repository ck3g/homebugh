require_relative '../../app/services/group_chart_data'

RSpec.describe GroupChartData, type: :service do
  describe "#group_smallest_categories" do
    subject { described_class.new(chart_data, 5).group_smallest_categories }

    context "when there is no groups at all" do
      let(:chart_data) { nil }

      it { is_expected.to eq({}) }
    end

    context "when there is more less than 5 groups" do
      let(:chart_data) do
        {
          category1: 10,
          category2: 20,
          category3: 30,
          category4: 40,
          category5: 50
        }
      end

      it "do not mutate the collection" do
        is_expected.to eq chart_data
      end
    end

    context "when there is more than 5 groups" do
      let(:chart_data) do
        {
          category1: 10,
          category2: 20,
          category3: 30,
          category4: 40,
          category5: 50,
          category6: 60,
          category7: 70,
          category8: 80,
          category9: 90
        }
      end

      it "group smallest categories" do
        is_expected.to eq(
          category9: 90,
          category8: 80,
          category7: 70,
          category6: 60,
          category5: 50,
          other: 100
        )
      end
    end
  end
end
