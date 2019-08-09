import PropTypes from 'prop-types'
import React from 'react'
import classNames from 'classnames/bind'
import Links from './Links'
import { asClassName } from '../util.js'

const propTypes = {
  model: PropTypes.object.isRequired,
  id: PropTypes.number.isRequired,
  rivals: PropTypes.array.isRequired,
  handleCheck: PropTypes.func.isRequired,
  disabled: PropTypes.bool.isRequired,
}

export default class ChallengeItem extends React.Component {
  isChecked() {
    return this.props.rivals[0] && this.props.rivals[0].checked[this.props.id]
  }
  handleCheck() {
    if (this.props.disabled) return
    this.props.model.check(this.props.id, !this.isChecked()).then(response => {
      this.props.handleCheck(this.props.id, response.checked)
    })
  }
  render() {
    const chall = this.props.model.challenge(this.props.id)
    const rivals = this.props.rivals
      .slice(1)
      .filter(rival => rival.checked[chall.id])
      .map(rival => {
        return (
          <img
            key={`ico-${rival.screen_name}`}
            src={rival.icon_url}
            alt={rival.screen_name}
          />
        )
      })
    return (
      <tr className={classNames({ checked: this.isChecked() })}>
        <td className="check" onClick={::this.handleCheck}>
          <i className="fa fa-check" aria-hidden="true" />
        </td>

        <td className={`difficulty ${asClassName(chall.difficulty)}`}>
          {chall.difficulty}
        </td>
        <td className="chall">{chall.name}</td>
        <td className="source">
          <Links chall={chall} />
          {chall.event}
        </td>
        <td className="solves">{chall.solves}</td>
        <td className="rival-ico">{rivals}</td>
      </tr>
    )
  }
}

ChallengeItem.propTypes = propTypes
