import React from 'react' // eslint-disable-line no-unused-vars
import ReactDOM from 'react-dom'
import Challenges from './components/Challenges'
import ChallengeModel from './challengeModel.js'
;(function() {
  const model = new ChallengeModel()
  ReactDOM.render(
    <Challenges model={model} />,
    document.getElementById('challs')
  )
})()
