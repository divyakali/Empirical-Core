"use strict";
EC.ActivitySearchResults = React.createClass({

	render: function () {
		var rows = _.map(this.props.currentPageSearchResults, function (ele) {
			var activityId = ele.id;
			var selectedIds = _.pluck(this.props.selectedActivities, 'id');
			var selected = _.include(selectedIds, activityId);
			return <EC.ActivitySearchResult data={ele} selected={selected} toggleActivitySelection={this.props.toggleActivitySelection} />
		}, this);
		return (
			<tbody>
				{rows}
			</tbody>
		);
	}
});