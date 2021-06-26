import { Categoria, stringToFiltros } from '@admin/domain';
import { CategoriaService, JwtAuthGuard } from '@admin/services';
import { Body, Controller, Get, Param, Post, Put, Query, UseGuards, UsePipes, ValidationPipe } from '@nestjs/common';

@Controller('categoria')
@UseGuards(JwtAuthGuard)
export class CategoriaController {

  constructor(
    private readonly categoriaService: CategoriaService
  ) { }

  @Get(':id')
  async get(@Param('id') id: string): Promise<Categoria> {
    return await this.categoriaService.get(id);
  }

  @Get()
  async pesquisar(@Query('filtros') filtros: string): Promise<Categoria[]> {
    return await this.categoriaService.pesquisar(stringToFiltros(filtros));
  }

  @Post()
  @UsePipes(new ValidationPipe({ transform: true }))
  async inserir(@Body() categoria: Categoria): Promise<Categoria> {
    return await this.categoriaService.inserir(categoria);
  }

  @Put(':id')
  @UsePipes(new ValidationPipe())
  async alterar(@Param('id') id: string, @Body() categoria: Categoria): Promise<Categoria> {
    return await this.categoriaService.alterar(id, categoria);
  }
}
