import PropTypes from 'prop-types'
import React from 'react'

const propTypes = {
  chall: PropTypes.object.isRequired,
}

export default class Links extends React.Component {
  link(iconName, url) {
    const icon = <i className={`fa fa-${iconName}`} aria-hidden="true" />
    return url ? (
      <a href={url} target="_blank" rel="noopener noreferrer">
        {icon}
      </a>
    ) : (
      icon
    )
  }
  render() {
    const chall = this.props.chall
    return (
      <span>
        {this.link('github', chall.github_link)}
        {this.link('file-archive-o', chall.download_link)}
        {this.link('external-link', chall.source_link)}
      </span>
    )
  }
}

Links.propTypes = propTypes
