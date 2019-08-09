import 'whatwg-fetch'

export default class ChallengeModel {
  constructor() {
    this.namespace = 'ctf4u'
    this.challenges = []
    this.options = null
    this.status = null
  }
  getChallenges() {
    return fetch('/ctf4u/api/challenge')
      .then(response => response.json())
      .then(json => {
        this.challenges = json.challenges
        this._challengesId = {}
        json.challenges.map(chall => {
          this._challengesId[chall.id] = chall
        })
        this.options = json.options
        this.status = json.status
        return json
      })
  }
  getRivals(rivals) {
    return fetch('/ctf4u/api/rival', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        rivals,
      }),
      credentials: 'same-origin',
    }).then(response => response.json())
  }
  check(id, checked) {
    const chall = this.challenge(id)
    return fetch('/ctf4u/api/check', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id,
        checked,
      }),
      credentials: 'same-origin',
    })
      .then(response => response.json())
      .then(response => {
        for (const k of Object.keys(response)) {
          chall[k] = response[k]
        }
        return response
      })
  }
  challenge(id) {
    return this._challengesId[id]
  }
  challengesFilter(filter, checked) {
    const ids = []
    this.challenges.forEach(chall => {
      if (filter.hideChecked && checked[chall.id]) return
      if (
        !this._range(
          chall.difficulty_id,
          filter.difficultyMin,
          filter.difficultyMax
        )
      )
        return
      if (filter.source !== null && chall.event_source_id !== filter.source)
        return
      if (
        chall.year !== null &&
        !this._range(chall.year, filter.yearMin, filter.yearMax)
      )
        return
      ids.push(chall.id)
    })
    return ids
  }
  _range(val, min, max) {
    return min <= val && val <= max
  }
  filterPickOne(ids, picked) {
    if (ids.length === 0) return null
    if (picked !== null && ids.find(id => id === picked)) {
      return picked
    }
    const randomIdx = Math.floor(Math.random() * ids.length)
    return ids[randomIdx]
  }
  storeFilter(data) {
    if (data) {
      return localStorage.setItem(this.namespace, JSON.stringify(data))
    }

    let filter = localStorage.getItem(this.namespace)
    if (filter) {
      filter = JSON.parse(filter)
    } else {
      filter = {
        rivals: [],
        difficultyMin: 1,
        difficultyMax: 6,
        source: null,
        yearMin: 2012,
        yearMax: 2016,
        hideChecked: false,
        pickOne: false,
        picked: null,
      }
    }
    return filter
  }
  searchFilter(stateFilter, assigned, checked) {
    const filter = Object.assign({}, stateFilter, assigned)
    let challenges = this.challengesFilter(filter, checked)
    if (filter.pickOne) {
      filter.picked = this.filterPickOne(challenges, filter.picked)
      if (filter.picked !== null) {
        challenges = [filter.picked]
      }
    }
    this.storeFilter(filter)
    return [challenges, filter]
  }
}
