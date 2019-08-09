import PropTypes from 'prop-types'
import React from 'react'
import Select from 'react-select'
import 'whatwg-fetch'

const propTypes = {
  value: PropTypes.array.isRequired,
  onChange: PropTypes.func.isRequired,
}

class Option extends React.Component {
  handleMouseDown(event) {
    event.preventDefault()
    event.stopPropagation()
    this.props.onSelect(this.props.option, event)
  }
  handleMouseEnter(event) {
    this.props.onFocus(this.props.option, event)
  }
  handleMouseMove(event) {
    if (this.props.isFocused) return
    this.props.onFocus(this.props.option, event)
  }
  render() {
    const option = this.props.option
    const difficultyName = [
      'baby',
      'easy',
      'medium-easy',
      'medium-medium',
      'medium-hard',
      'hard',
    ]
    const challBar = option.solves_count.map((count, i) => {
      const style = {
        width: `${count / 2}px`,
      }
      return (
        <div
          key={`${this.props.screen_name}-chall-bar-${i}`}
          className={`chall-bar-color ${difficultyName[i]}`}
          style={style}
        />
      )
    })
    return (
      <div
        className={this.props.className}
        onMouseDown={::this.handleMouseDown}
        onMouseEnter={::this.handleMouseEnter}
        onMouseMove={::this.handleMouseMove}
        title={this.props.option.screen_name}
      >
        <div className="rival-name">{option.screen_name}</div>
        <div className="solves">{option.solves}</div>
        <div className="chall-bar">{challBar}</div>
        <div className="clearfix" />
      </div>
    )
  }
}

export default class RivalSelect extends React.Component {
  searchUsers(input) {
    return fetch(`/ctf4u/api/search/user?q=${input}`, {
      credentials: 'same-origin',
    })
      .then(response => response.json())
      .then(options => {
        return { options }
      })
  }
  handleFocus() {
    // no bind this
    this.onInputChange('')
  }
  render() {
    return (
      <Select.Async
        multi={true}
        autoload={false}
        value={this.props.value}
        onChange={::this.props.onChange}
        onFocus={this.handleFocus}
        loadOptions={::this.searchUsers}
        optionComponent={Option}
        valueKey="screen_name"
        labelKey="screen_name"
        searchPromptText="入力して検索"
        loadingPlaceholder="読み込み中"
        placeholder="ライバルのID"
      />
    )
  }
}

RivalSelect.propTypes = propTypes
