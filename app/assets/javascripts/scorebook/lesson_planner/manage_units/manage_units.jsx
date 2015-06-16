"use strict";
EC.ManageUnits = React.createClass({
	propTypes: {
		toggleTab: React.PropTypes.func.isRequired,
		editIndividualUnit: React.PropTypes.func.isRequired
	},

	getInitialState: function () {
		return {
			units: []
		}
	},

	componentDidMount: function () {
		$.ajax({
			url: '/teachers/units',
			data: {},
			success: this.displayUnits,
			error: function () {
			}

		});
	},
	
	displayUnits: function (data) {
		this.setState({units: data.units});
	},
	
	deleteUnit: function (id) {
		var units, x1;
		units = this.state.units;
		x1 = _.reject(units, function (unit) {
			return unit.unit.id == id;
		})
		this.setState({units: x1});

		$.ajax({
			type: "delete",
			url: "/teachers/units/" + id,
			success: function () {
			},
			error: function () {
			}
		});
	},

	deleteActivityAssignment: function (unitId, activityId) {
		var units, x1;
		units = this.state.units;
		x1 = _.map(units, function (unit) {
			if (unit.unit.id === unitId) {
				unit.activity_assignments = _.reject(unit.activity_assignments, function (as) {
					return as.activity.id === activityId;
				});
			}
			return unit;
		});
		this.setState({units: x1});

		$.ajax({
			type: "delete",
			url: "/teachers/units/" + unitId + "/activity_assignments/" + activityId,
			success: function () {
			},
			error: function () {
			}
		});
	},
	
	updateDueDate: function (unitId, activityId, date) {
		$.ajax({
			type: "put",
			data: {due_date: date},
			url: "/teachers/units/" + unitId + "/activity_assignments/" + activityId,
			success: function () {
			},
			error: function () {
			}

		});
	},
	
	switchToCreateUnit: function () {
		this.props.toggleTab('createUnit');
	},
	
	render: function () {
		var units = _.map(this.state.units, function (unit) {
			return (<EC.Unit
							unit={unit}
							editUnit={this.props.editIndividualUnit}
							deleteUnit={this.deleteUnit}
							updateDueDate={this.updateDueDate}
							deleteActivityAssignment={this.deleteActivityAssignment}/>);
		}, this);
		return (
			<div className="container manage-units">
				<div  className= "create-unit-button-container">
					<button onClick={this.switchToCreateUnit} className="button-green create-unit">Create a New Unit</button>
				</div>
				<span>
					{units}
				</span>
			</div>
		);
	}
});