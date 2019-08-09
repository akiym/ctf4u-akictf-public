import PropTypes from 'prop-types'
import React from 'react'
import Challenges from './Challenges'

const propTypes = {
  model: PropTypes.object.isRequired,
}

export default class App extends React.Component {
  constructor(props, context) {
    super(props, context)
    this.state = {
      // TODO localStorage
      rivals: [],
      rivalStatus: {},
    }
  }
  render() {
    return (
      <div>
        <Challenges
          model={this.props.model}
          rivals={this.state.rivals}
          rivalStatus={this.state.rivalStatus}
        />
      </div>
    )
  }
}

App.propTypes = propTypes
