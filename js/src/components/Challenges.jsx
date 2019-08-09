import PropTypes from 'prop-types'
import React from 'react'
import Select from 'react-select'
import RivalSelect from './RivalSelect'
import DifficultySelect from './DifficultySelect'
import ChallengeStatus from './ChallengeStatus'
import ChallengeItem from './ChallengeItem'

const propTypes = {
  model: PropTypes.object.isRequired,
}

export default class Challenges extends React.Component {
  constructor(props, context) {
    super(props, context)
    this.state = {
      challenges: [],
      rivals: [],
      filter: props.model.storeFilter(),
    }
  }
  componentDidMount() {
    Promise.all([
      this.getRivals(this.state.filter.rivals),
      this.props.model.getChallenges(),
    ]).then(() => {
      this.setFilter({})
    })
  }
  getRivals(rivals) {
    this.props.model
      .getRivals(rivals.map(rival => rival.screen_name))
      .then(rivals_ => {
        this.setState({ rivals: rivals_ })
      })
  }
  handleRivalSelect(rivals) {
    this.setFilter({ rivals })
    this.getRivals(rivals)
  }
  handleChangeMinValue(val, minName, maxName) {
    const min = val.value
    this.setFilter({
      [minName]: min,
      [maxName]: Math.max(min, this.state.filter[maxName]),
    })
  }
  handleChangeMaxValue(val, minName, maxName) {
    const max = val.value
    this.setFilter({
      [minName]: Math.min(max, this.state.filter[minName]),
      [maxName]: max,
    })
  }
  handleCheck(id, checked) {
    if (this.state.rivals[0]) {
      const rivals = this.state.rivals.slice()
      const chall = this.props.model.challenge(id)
      const amount = checked ? +1 : -1
      rivals[0].solves += amount
      rivals[0].solves_count[chall.difficulty_id - 1] += amount
      rivals[0].checked[id] = checked
      this.setState({ rivals })
    }
  }
  setFilter(assigned) {
    const checked = (this.state.rivals[0] && this.state.rivals[0].checked) || {}
    const [challenges, filter] = this.props.model.searchFilter(
      this.state.filter,
      assigned,
      checked
    )
    this.setState({
      challenges,
      filter,
    })
  }
  options(name) {
    return (this.props.model.options && this.props.model.options[name]) || []
  }
  render() {
    const disableCheck = !this.state.rivals[0]
    const challs = this.state.challenges.map(id => {
      return (
        <ChallengeItem
          key={`chall-${id}`}
          model={this.props.model}
          id={id}
          rivals={this.state.rivals}
          handleCheck={::this.handleCheck}
          disabled={disableCheck}
        />
      )
    })
    const difficultyOptions = this.options('difficulty')
    const sourceOptions = this.options('event_source')
    const yearOptions = this.options('year')
    return (
      <div>
        <div id="query-form" className="row">
          <div className="form-horizontal col-sm-6">
            <div className="form-group">
              <label className="col-sm-2 control-label">難易度</label>
              <div className="column col-sm-10">
                <DifficultySelect
                  value={this.state.filter.difficultyMin}
                  options={difficultyOptions}
                  onChange={val =>
                    ::this.handleChangeMinValue(
                      val,
                      'difficultyMin',
                      'difficultyMax'
                    )
                  }
                />
                <DifficultySelect
                  value={this.state.filter.difficultyMax}
                  options={difficultyOptions}
                  onChange={val =>
                    ::this.handleChangeMaxValue(
                      val,
                      'difficultyMin',
                      'difficultyMax'
                    )
                  }
                />
              </div>
            </div>
            <div className="form-group">
              <label className="col-sm-2 control-label">ライバル</label>
              <div className="col-sm-10">
                <RivalSelect
                  value={this.state.filter.rivals}
                  onChange={::this.handleRivalSelect}
                />
              </div>
            </div>
          </div>
          <div className="form-horizontal col-sm-6">
            <div className="form-group">
              <label className="col-sm-2 control-label">出典</label>
              <div className="col-sm-10">
                <Select
                  value={this.state.filter.source}
                  options={sourceOptions}
                  onChange={val =>
                    ::this.setFilter({ source: (val && val.value) || null })
                  }
                  noResultsText="見つかりません"
                  placeholder=""
                />
              </div>
            </div>
            <div className="form-group">
              <label className="col-sm-2 control-label">年代</label>
              <div className="column col-sm-10">
                <Select
                  clearable={false}
                  searchable={false}
                  value={this.state.filter.yearMin}
                  options={yearOptions}
                  onChange={val =>
                    ::this.handleChangeMinValue(val, 'yearMin', 'yearMax')
                  }
                  placeholder=""
                />
                <Select
                  clearable={false}
                  searchable={false}
                  value={this.state.filter.yearMax}
                  options={yearOptions}
                  onChange={val =>
                    ::this.handleChangeMaxValue(val, 'yearMin', 'yearMax')
                  }
                  placeholder=""
                />
              </div>
            </div>
            <div className="form-group">
              <label className="col-sm-2 control-label">オプション</label>
              <div className="col-sm-10">
                <div className="checkbox">
                  <label>
                    <input
                      type="checkbox"
                      onChange={event =>
                        ::this.setFilter({ hideChecked: event.target.checked })
                      }
                      checked={this.state.filter.hideChecked}
                    />{' '}
                    解いた問題を隠す
                  </label>
                </div>
                <div className="checkbox">
                  <label>
                    <input
                      type="checkbox"
                      onChange={event =>
                        ::this.setFilter({
                          pickOne: event.target.checked,
                          picked: null,
                        })
                      }
                      checked={this.state.filter.pickOne}
                    />{' '}
                    今日の1問
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>
        <ChallengeStatus model={this.props.model} rivals={this.state.rivals} />
        <table id="challenge" className="table table-bordered">
          <thead>
            <tr>
              <th className="check" />
              <th className="difficulty">難易度</th>
              <th className="chall">問題名</th>
              <th className="source">出典</th>
              <th className="solves">解いた人数</th>
              <th className="rival">解いたライバル</th>
            </tr>
          </thead>
          <tbody>{challs}</tbody>
        </table>
      </div>
    )
  }
}

Challenges.propTypes = propTypes
