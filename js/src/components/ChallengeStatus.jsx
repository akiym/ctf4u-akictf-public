import PropTypes from 'prop-types'
import React from 'react'
import { asClassName } from '../util.js'

const propTypes = {
  model: PropTypes.object.isRequired,
  rivals: PropTypes.array.isRequired,
}

export default class ChallengeStatus extends React.Component {
  style(i, count) {
    const progress = count / this.props.model.status.solves_count[i]
    return [
      { background: `rgba(187, 187, 187, ${progress})` },
      { background: `rgba(137, 255, 137, ${progress})` },
      { background: `rgba(131, 131, 255, ${progress})` },
      { background: `rgba(254, 254, 85, ${progress})` },
      { background: `rgba(255, 153, 85, ${progress})` },
      { background: `rgba(255, 100, 100, ${progress})` },
    ][i]
  }
  render() {
    const options = this.props.model.options
    const status = this.props.model.status
    if (!options) return false

    const difficultyClasses = options.difficulty.map(value => {
      return `difficulty ${asClassName(value.label)}`
    })
    const pointColumns = options.difficulty.map((difficulty, i) => {
      return (
        <th key={`point-columns-${i}`} className={difficultyClasses[i]}>
          {difficulty.label}
        </th>
      )
    })
    const totalSolvesCount = status.solves_count.map((count, i) => {
      return (
        <th key={`total-solves-count-${i}`} className={difficultyClasses[i]}>
          {count}
        </th>
      )
    })
    const users = this.props.rivals
      .slice()
      .filter(user => user !== null)
      .sort((a, b) => b.solves - a.solves)
      .map((user, i) => {
        const solvesCount = user.solves_count.map((count, j) => {
          return (
            <td
              key={`solves-count-${user.screen_name}-${j}`}
              className="difficulty"
              style={this.style(j, count)}
            >
              {count}
            </td>
          )
        })
        return (
          <tr key={`status-${user.screen_name}`}>
            <td className="rank">{i + 1}</td>
            <td className="rival-ico">
              <img src={user.icon_url} />
            </td>
            <td>{user.screen_name}</td>
            <td className="solves">{user.solves}</td>
            {solvesCount}
          </tr>
        )
      })
    return (
      <table id="challenge-status" className="table table-bordered">
        <thead>
          <tr>
            <th className="rank">#</th>
            <th colSpan="2">ID</th>
            <th className="solves">解いた数</th>
            {pointColumns}
          </tr>
          <tr>
            <th className="rank" />
            <th colSpan="2">TOTAL</th>
            <th className="solves">{status.solves}</th>
            {totalSolvesCount}
          </tr>
        </thead>
        <tbody>{users}</tbody>
      </table>
    )
  }
}

ChallengeStatus.propTypes = propTypes
