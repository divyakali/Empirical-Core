// The progress report showing all students in a given classroom
// along with their result counts.

EC.ConceptsStudentsProgressReport = React.createClass({
  propTypes: {
    sourceUrl: React.PropTypes.string.isRequired
  },

  getInitialState: function() {
    return {
      students: {}
    }
  },

  columnDefinitions: function() {
    return [
      {
        name: 'Name',
        field: 'name',
        sortByField: 'name',
        customCell: function(row) {
          return (
            <a className="concepts-view" href={row['concepts_href']}>{row['name']}</a>
          );
        }
      },
      {
        name: 'Questions',
        field: 'total_result_count',
        sortByField: 'total_result_count'
      },
      {
        name: 'Correct',
        field: 'correct_result_count',
        sortByField: 'correct_result_count'
      },
      {
        name: 'Incorrect',
        field: 'incorrect_result_count',
        sortByField: 'incorrect_result_count'
      },
      {
        name: 'Percentage',
        field: 'percentage',
        sortByField: 'percentage',
        customCell: function(row) {
          return row['percentage'] + '%';
        }
      }
    ];
  },

  sortDefinitions: function() {
    return {
      config: {
        name: 'natural',
        total_result_count: 'numeric',
        correct_result_count: 'numeric',
        incorrect_result_count: 'numeric',
        percentage: 'numeric'
      },
      default: {
        field: 'name',
        direction: 'asc'
      }
    };
  },

  onFetchSuccess: function(responseData) {
    this.setState({
      students: responseData.students
    });
  },

  render: function() {
    return (
      <EC.ProgressReport columnDefinitions={this.columnDefinitions}
                         pagination={false}
                         sourceUrl={this.props.sourceUrl}
                         sortDefinitions={this.sortDefinitions}
                         jsonResultsKey={'students'}
                         onFetchSuccess={this.onFetchSuccess}
                         filterTypes={[]}>
        <h2>Results by Student</h2>
      </EC.ProgressReport>
    );
  }
});