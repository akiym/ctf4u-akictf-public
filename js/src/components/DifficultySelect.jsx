import PropTypes from 'prop-types'
import React from 'react'
import Select from 'react-select'
import { asClassName } from '../util.js'

const propTypes = {
  value: PropTypes.number.isRequired,
  options: PropTypes.array.isRequired,
  onChange: PropTypes.func.isRequired,
}

class DifficultyBox extends React.Component {
  render() {
    return (
      <span
        className={`difficulty-box ${asClassName(this.props.difficulty)}`}
      />
    )
  }
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
    return (
      <div
        className={this.props.className}
        onMouseDown={::this.handleMouseDown}
        onMouseEnter={::this.handleMouseEnter}
        onMouseMove={::this.handleMouseMove}
        title={this.props.option.title}
      >
        <DifficultyBox difficulty={this.props.children} />
        {this.props.children}
      </div>
    )
  }
}

class Value extends React.Component {
  render() {
    return (
      <div className="Select-value" title={this.props.value.title}>
        <span className="Select-value-label">
          <DifficultyBox difficulty={this.props.children} />
          {this.props.children}
        </span>
      </div>
    )
  }
}

export default class DifficultySelect extends React.Component {
  render() {
    return (
      <Select
        value={this.props.value}
        clearable={false}
        searchable={false}
        onChange={::this.props.onChange}
        options={this.props.options}
        optionComponent={Option}
        valueComponent={Value}
        placeholder=""
      />
    )
  }
}

DifficultySelect.propTypes = propTypes
