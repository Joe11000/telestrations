import React from 'react'
import {shallow} from 'enzyme'
import GameSelector from 'packs/postgame/GameSelector'
import {render, fireEvent} from 'react-testing-library'

import enzymeSerializer from 'enzyme-to-json/serializer'
expect.addSnapshotSerializer(enzymeSerializer)

describe('GameSelector Component', ()=>{
  // describe('proptypes', ()=>{
  //   // props = {
  //   //           all_postgames_of__current_user: PropTypes.shape({
  //   //             id: PropTypes.number.isRequired,
  //   //             created_at_strftime: PropTypes.string.isRequired
  //   //           }),
  //   //           retrieveCardsForPostgame: PropTypes.func.isRequired

  //   //         }
  // })
  it('sets correct values', ()=>{
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

                    'retrieveCardsForPostgame': mockRetrieveCardsForPostgame
                  }

    const game_selector = shallow(<GameSelector {...props} />)

    // expect(mockRetrieveCardsForPostgame).toBeCalled()
    // expect(mockRetrieveCardsForPostgame).toBeCalledWith(game_3.id)
    expect( game_selector).toMatchSnapshot();

    // expect( game_selector.containsAllMatchingElements([
    //                                                    <option value={game_1.id}>Game 1 - {game_1.created_at_strftime}</option>,
    //                                                    <option value={game_2.id}>Game 2 - {game_2.created_at_strftime}</option>,
    //                                                    <option value={game_3.id}>Game 3 - {game_3.created_at_strftime}</option>
    //                                                  ]) ).toEqual(true);


  })
})



