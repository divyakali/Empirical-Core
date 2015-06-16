"use strict";
EC.ActivityAssignment = React.createClass({
	propTypes: {
		activityAssignment: React.PropTypes.object.isRequired,
		unitId: React.PropTypes.integer.isRequired,
		updateDueDate: React.PropTypes.func.isRequired,
		deleteActivityAssignment: React.PropTypes.func.isRequired
	},
	componentDidMount: function () {
		$(this.refs.dueDate.getDOMNode()).datepicker({
	    	selectOtherMonths: true,
	      	dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
	      	minDate: -20,
	      	maxDate: "+1M +10D",
	      	dateFormat: "mm-dd-yy",
	      	altField: ('#railsFormatDate' + this.getActivityAssignmentId()),
	      	altFormat: 'yy-mm-dd',
	      	onSelect: this.handleChange
	    });

	},
	getActivityAssignmentId: function () {
		return this.props.unitId + "-" + this.props.activity.id
	},
	deleteActivityAssignment: function () {
		var x = confirm("Are you sure you want do delete this assignment?");
		if (x) {
			this.props.deleteActivityAssignment(this.props.id, this.props.unit_id);
		}
	},

	handleChange: function () {
	    var x1, dom, val;
	    x1 = '#railsFormatDate' + this.getActivityAssignmentId();
	    dom = $(x1);
	    val = dom.val();
	    this.props.updateDueDate(this.props.unitId, this.props.activityAssignment.activity.id, val);
	},

	render: function () {

		return (
			<div className="row">
				<div className="cell col-md-1">
					<div className={"pull-left icon-gray icon-wrapper  " + this.props.activityAssignment.activity.classification.scorebook_icon_class} />
				</div>
				<div className="cell col-md-8" >
					<a href={this.props.activityAssignment.activity.anonymous_path} target="_new">
						{this.props.activityAssignment.activity.name}
					</a>
				</div>
				<div className="cell col-md-2">
					<input type="text" value={this.props.activityAssignment.formatted_due_date} ref="dueDate" className="datepicker-input" placeholder="mm/dd/yyyy" />
					<input type="text"  className="railsFormatDate" id={"railsFormatDate" + this.getActivityAssignmentId()} ref="railsFormatDate" />
				</div>
				<div className="cell col-md-1">
					<div className="pull-right icon-x-gray" onClick={this.deleteActivityAssignment}>
					</div>
				</div>
			</div>

		);
	}
});