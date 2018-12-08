import React from 'react'
import {shallow} from 'enzyme'
import PostGameTab from 'packs/postgame/TabBody/PostGameTab'
import {render, fireEvent} from 'react-testing-library'

import enzymeSerializer from 'enzyme-to-json/serializer'
expect.addSnapshotSerializer(enzymeSerializer)

describe('PostGameTab Component', ()=>{
  it('renders correctly', () => {
      let game_1 = {'id': 11, 'created_at_strftime': 'Mon Nov 1, 2018'}
      let game_2 = {'id': 22, 'created_at_strftime': 'Tues Nov 2, 2018'}
      let game_3 = {'id': 33, 'created_at_strftime': 'Wed Nov 3, 2018'}

      const mockRetrieveCardsForPostgame = jest.fn()

      let props = {
                      'all_postgames_of__current_user': [
                                                          {
                                                            'id': game_1.id,
                                                            'created_at_strftime': game_1.created_at_strftime
                                                          },
                                                          {
                                                            'id': game_2.id,
                                                            'created_at_strftime': game_2.created_at_strftime
                                                          },
                                                          {
                                                            'id': game_3.id,
                                                            'created_at_strftime': game_3.created_at_strftime
                                                          }
                                                        ],

                      'current_postgame_id': game_3.id,
                      'retrieveCardsForPostgame': mockRetrieveCardsForPostgame
                    }

      const postgame_tab = shallow(<PostGameTab {...props} />)

  })
});
