var PageTitle = createReactClass({
  propTypes: {
    title: PropTypes.string
  },

  render: function() {
    return (
      <h2>{this.props.title}</h2>
    );
  }
});